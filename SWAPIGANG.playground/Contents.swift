import UIKit

struct Person:  Decodable {
    let name: String
    let films: [URL]
}

struct Film: Decodable {
    let title: String
    let opening_crawl: String
    let release_date: String
}

class SwapiService {
    static let baseURL = URL(string: "https://swapi.dev/api/")
    static let personEndpoint = "people/"
    static let filmEndpoint = "film"
    
    static func fetchPerson(id: Int, completion: @escaping (Person?) -> Void) {
        //1 - Prepare URL
        guard let baseURL = baseURL else { return completion(nil) }
        let charID = String(id)
        let personURL = baseURL.appendingPathComponent(personEndpoint)
        let finalURL = personURL.appendingPathComponent(charID)
        //https://api.publicapis.org/people
        
        print(finalURL)
        //2 - Contact Server
        URLSession.shared.dataTask(with: finalURL) { (data, _, error) in
            //3 Handle Errors
            if let  error = error {
                print(error)
                print(error.localizedDescription)
                return completion(nil)
            }
            //4 Check for Data
            guard let data = data else { return completion(nil) }
            //5 Decode Person from JSON
            do {
                let decoder = JSONDecoder()
                let person = try decoder.decode(Person.self , from: data)
                
                for url in person.films {
                    startFilmFetch(url: url)
                }
                
                return completion(person)
            } catch {
                print(error)
                print(error.localizedDescription)
                return completion(nil)
            }
        }.resume()
    }
    
    static func fetchFilm(url: URL, completion: @escaping (Film?) -> Void){
        //1 - Contact
        URLSession.shared.dataTask(with: url) { (data,_,error) in
            //2 - Handle Errors
            if let  error = error {
                print(error)
                print(error.localizedDescription)
                return completion(nil)
            }
            //3 - Check for Data
            guard let data = data else { return completion(nil) }
            //4 - Decode Film from JSON
            do {
                let decoder = JSONDecoder()
                let film = try decoder.decode(Film.self , from: data)
                return completion(film)
            } catch {
                print(error)
                print(error.localizedDescription)
                return completion(nil)
            }
        }.resume()
    }
}//end of Class

func startFilmFetch(url: URL) {
    SwapiService.fetchFilm(url: url) { film in
        if let film = film {
        print(film)
        }
    }
}

SwapiService.fetchPerson(id: 1) { (person) in
    if let person = person {
        print(person)
    }
}
