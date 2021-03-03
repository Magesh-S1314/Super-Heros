//
//  NetworkManager.swift
//  Super Heros
//
//  Created by magesh on 03/03/21.
//

import Foundation
import UIKit

struct NetworkError: Error, LocalizedError {
    let errorDescription: String?
    
    init(_ description: String) {
        errorDescription = description
    }
    
    static var invalidURL = NetworkError("Invalid URL")
    static var NoResponseError = NetworkError("No Response from server")
}

enum HTTPMethod: String {
    case GET, POST, PUT, UPDATE, DELETE, OPTION, HEAD
}

final class NetworkManager {
        
    var sessionConfiguration: URLSessionConfiguration
    var jsonDecoder: JSONDecoder
    
    init(configuration: URLSessionConfiguration = .default, jsonDecoder: JSONDecoder = JSONDecoder()){
        self.sessionConfiguration = configuration
        self.jsonDecoder = jsonDecoder
    }
    
    static let shared = NetworkManager()
    
    var defaultHeaders = [
        "Content-Type": "application/json",
        "Accept": "application/json",
    ]
    
    public func get<T: Decodable>(url: String, query: [String: String]? = nil, headers: [String: String] = [:], completion: @escaping (Result<T, Error>)->Void) {
        var newUrl = url
        if let query = query {
            newUrl = newUrl + query.first!.key + "/" + query.first!.value
        }
        
        guard var url = URL(string: newUrl) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        if let query = query {
            guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                completion(.failure(NetworkError.invalidURL))
                return
            }
            urlComponents.queryItems = query.map { URLQueryItem(name: $0, value: $1) }
            guard let urlWithQuery = urlComponents.url else {
                completion(.failure(NetworkError.invalidURL))
                return
            }
            url = urlWithQuery
        }
        
        
        print("url \(url)")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HTTPMethod.GET.rawValue
        defaultHeaders.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
        headers.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
        
        
        let session = URLSession(configuration: sessionConfiguration)
        session.dataTask(with: urlRequest as URLRequest, completionHandler: { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            let result: Result<T, Error> = self.decodeJsonAndCreateModel(data: data, response: response, error: error)
            DispatchQueue.main.async {
                completion(result)
            }
            
        }).resume()
    }
    
    func post<T: Decodable>(url: String, body: [String: Any], headers: [String: String] = [:], completion: @escaping (Result<T, Error>)->Void) {
        serializedRequest(method: .POST, url: url, body: body, completion: completion)
    }
    
    func put<T: Decodable>(url: String, body: [String: Any], headers: [String: String] = [:], completion: @escaping (Result<T, Error>)->Void) {
        serializedRequest(method: .PUT, url: url, body: body, completion: completion)
    }
    
    func delete<T: Decodable>(url: String, body: [String: Any], headers: [String: String] = [:], completion: @escaping (Result<T, Error>)->Void) {
        serializedRequest(method: .DELETE, url: url, body: body, completion: completion)
    }
    
    func update<T: Decodable>(url: String, body: [String: Any], headers: [String: String] = [:], completion: @escaping (Result<T, Error>)->Void) {
        serializedRequest(method: .UPDATE, url: url, body: body, completion: completion)
    }
    
    func fileUpload<T: Decodable>(url: String, formFields: [String: String] = [:], images: [String : Data], completion: @escaping (Result<T, Error>)->Void) {
        fileUpload(method: .POST, url: url, formFields: formFields, images: images, completion: completion)
    }
    
    private func serializedRequest<T: Decodable>(method: HTTPMethod, url:String, body: [String: Any], headers: [String: String] = [:], completion: @escaping (Result<T, Error>)->Void) {
        
        guard let url = URL(string: url) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        urlRequest.httpMethod = method.rawValue
        defaultHeaders.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
        headers.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
        
        print("url - \(url)")
        print("body - \(body)")
       
        let session = URLSession(configuration: sessionConfiguration)
        session.dataTask(with: urlRequest as URLRequest, completionHandler: { [weak self] (data, response, error) in
            guard let self = self else { return }
            do {
                // make sure this JSON is in the format we expect
                if let json = try JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? [String: Any] {
                    // try to read out a string array
                    print("RESPONSE::::::\(json)")

                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
            
            let model: Result<T, Error> = self.decodeJsonAndCreateModel(data: data, response: response, error: error)
            DispatchQueue.main.async {
                completion(model)
            }
        }).resume()
    }
    
    private func decodeJsonAndCreateModel<T: Decodable>(data: Data?, response: URLResponse?, error: Error?) -> Result<T, Error> {
        if let error = error {
            return .failure(error)
        }
        else {
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(NetworkError.NoResponseError)
            }
            
            guard let data = data else {
                return .failure(NetworkError("No Data returned"))
            }
             
            do {
                guard (200..<300) ~= httpResponse.statusCode else {
                    let model = try self.jsonDecoder.decode(ErrorModel.self, from: data)
                    
                    if model.message == unauthorized{
                        return .failure(NetworkError(model.message))
                    }
                    return .failure(NetworkError(model.message))
                }
                
                let model = try self.jsonDecoder.decode(T.self, from: data)
                return .success(model)
            }catch let error {
                //decoding error
                print(error)
                return .failure(NetworkError("Something went wrong"))
            }
        }
    }
    
    func fileUpload<T: Decodable>(method: HTTPMethod, url:String, formFields: [String: String] = [:], images: [String: Data], completion: @escaping (Result<T, Error>)->Void) {
        
        guard let url = URL(string: url) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        
        request.httpMethod = method.rawValue
        defaultHeaders.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let httpBody = NSMutableData()
        for (key, value) in formFields {
          httpBody.appendString(convertFormField(named: key, value: value, using: boundary))
        }
        
        for (key, value) in images {
            httpBody.append(convertFileData(fieldName: key,
                                            fileName: "imagename.png",
                                            mimeType: "image/png",
                                            fileData: value,
                                            using: boundary))
            
        }
        httpBody.appendString("--\(boundary)--")

        request.httpBody = httpBody as Data
        
        print("url - \(url)")
        print("body - \(String(data: httpBody as Data, encoding: .utf8))")
        
        let session = URLSession(configuration: sessionConfiguration)
        session.dataTask(with: request as URLRequest, completionHandler: { [weak self] (data, response, error) in
            guard let self = self else { return }
            do {
                // make sure this JSON is in the format we expect
                if let json = try JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? [String: Any] {
                    // try to read out a string array
                    print("RESPONSE::::::\(json)")

                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
            let model: Result<T, Error> = self.decodeJsonAndCreateModel(data: data, response: response, error: error)
            DispatchQueue.main.async {
                completion(model)
            }
        }).resume()
    }
    
    func convertFormField(named name: String, value: String, using boundary: String) -> String {
      var fieldString = "--\(boundary)\r\n"
      fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
      fieldString += "\r\n"
      fieldString += "\(value)\r\n"

      return fieldString
    }
    
    func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
      let data = NSMutableData()

      data.appendString("--\(boundary)\r\n")
      data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
      data.appendString("Content-Type: \(mimeType)\r\n\r\n")
      data.append(fileData)
      data.appendString("\r\n")

      return data as Data
    }
    

}

extension NSMutableData {
  func appendString(_ string: String) {
    if let data = string.data(using: .utf8) {
      self.append(data)
    }
  }
}

//MARK:- Network mananger endpoints extension
extension NetworkManager {
    
    func get<T: Decodable>(data: Any? = nil, query: [String: String]? = nil, headers: [String: String] = [:], completion: @escaping (Result<T, Error>)->Void) {
        self.get(url: Endpoints.baseUrl.fullUrl(data: data), query: query, headers: headers, completion: completion)
    }
    
    func post<T: Decodable>(data: Any? = nil, body: [String: Any], headers: [String: String] = [:], completion: @escaping (Result<T, Error>)->Void) {
        self.post(url: Endpoints.baseUrl.fullUrl(data: data), body: body, headers: headers, completion: completion)
    }
    
    func put<T: Decodable>(data: Any? = nil, body: [String: Any], headers: [String: String] = [:], completion: @escaping (Result<T, Error>)->Void) {
        self.put(url: Endpoints.baseUrl.fullUrl(data: data), body: body, headers: headers, completion: completion)
    }
    
    func delete<T: Decodable>(data: Any? = nil, body: [String: Any], headers: [String: String] = [:], completion: @escaping (Result<T, Error>)->Void) {
        self.delete(url: Endpoints.baseUrl.fullUrl(data: data), body: body, headers: headers, completion: completion)
    }
    
    func update<T: Decodable>(data: Any? = nil, body: [String: Any], headers: [String: String] = [:], completion: @escaping (Result<T, Error>)->Void) {
        self.update(url: Endpoints.baseUrl.fullUrl(data: data), body: body, headers: headers, completion: completion)
    }
    
    func fileUpload<T: Decodable>(data: Any? = nil, formFields: [String: String] = [:], images: [String : Data], completion: @escaping (Result<T, Error>)->Void) {
        self.fileUpload(url: Endpoints.baseUrl.fullUrl(data: data), formFields: formFields, images: images, completion: completion)
    }
    
}



