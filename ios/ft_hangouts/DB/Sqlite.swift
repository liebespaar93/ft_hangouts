//
//  Sqlite.swift
//  ft_hangouts
//
//  Created by topknell on 4/12/24.
//

import SQLite3
import Foundation



struct AddressBookType {
    var id : Int32? //INTEGER PRIMARY KEY AUTOINCREMENT
    var first_name : String? //TEXT
    var last_name : String?  //TEXT
    var image : Date? // BLOB
    var phone_number : String // TEXT UNIQUE NOT NULL
    var create_date : String? //DATE DEFAULT CURRENT_TIMESTAMP NOT NULL
    var update_date : String? //DATE DEFAULT CURRENT_TIMESTAMP NOT NULL
}

class SQLiteController {
    static let shared = SQLiteController()
    
    var db: OpaquePointer?
    var healthCheck: Int32?
    let path = "addressbook.sqlite"
    
    init() {
        self.db = self.opeanDB()
        if (self.db != nil){
            createDB()
        }
    }
    
    deinit {
        self.healthCheck = sqlite3_close(self.db)
    }
    
    func opeanDB() -> OpaquePointer? {
        var db: OpaquePointer? = nil
        self.healthCheck = SQLITE_ERROR
        
        do {
            let filePath = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(path)
            self.healthCheck = sqlite3_open_v2(
                filePath.path, 
                &db,
                SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_MAIN_DB,
                nil)
            if (self.healthCheck == SQLITE_OK) {
                print("SQLite open Success.")
                return db
            }
        }
        catch {
            print("ERROR SQLite OPEN ", error.localizedDescription)
        }
        return nil
    }
    
    func createDB() {
        if (createAddressBookTable() != SQLITE_DONE){
            return;
        }
        print("createAddressBookTable")
//        if (createAddressBookUpdateTrigger() != SQLITE_DONE){
//            return ;
//        }
//        print("createAddressBookUpdateTrigger")
    }
    
    func createAddressBookTable() -> Int32 {
        let zSql = """
            CREATE TABLE IF NOT EXISTS AddressBook (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                first_name TEXT,
                last_name TEXT,
                image BLOB,
                phone_number TEXT UNIQUE NOT NULL,
                create_date DATE DEFAULT CURRENT_TIMESTAMP NOT NULL,
                update_date DATE DEFAULT CURRENT_TIMESTAMP NOT NULL,
                CHECK (phone_number GLOB '010-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]')
            )
        """
        let nByte : Int32 = Int32(zSql.count);
        let rc: Int32 = SQLiteQuere(zSql: zSql, nByte: nByte);
        
        print("createAddressBookTable ", rc)

        return (rc)
    }
    
    func createAddressBookUpdateTrigger() -> Int32 {
        let zSql = """
            CREATE TRIGGER updateAddressBook
            AFTER UPDATE ON AddressBook
            FOR EACH ROW
            BEGIN
                UPDATE AddressBook
                SET (create_date, update_date) = (old.create_date, CURRENT_TIMESTAMP)
                WHERE phone_number = new.phone_number;
            END
        """
        let nByte : Int32 = Int32(zSql.count)
        let rc: Int32 = SQLiteQuere(zSql: zSql, nByte: nByte)
        
        print("createTriggerUpdate ", rc)
        return (rc)
    }
    
    
    func insertAddressBook(first_name: String, last_name: String, phone_number: String) -> Int32 {
        let zSql = """
        INSERT INTO AddressBook (first_name,last_name,phone_number) VALUES (?,?,?);
        """
        let nByte : Int32 = Int32(zSql.count)
        let phoneRegex = try! NSRegularExpression(pattern: "^010-[0-9]{4}-[0-9]{4}$")
        
        let match = phoneRegex.firstMatch(in: phone_number, range: NSRange(location: 0, length: phone_number.count))
        if (match == nil){
            print("phone_number match fail")
            return (SQLITE_MISMATCH);
        }
        
        let contact = AddressBookType( // Auto-increment, set to 0
          first_name: "John",
          last_name: "Doe",
          phone_number: "010-1234-5678")

        
        let rc: Int32 = SQLiteQuere(
            zSql: zSql,
            nByte: nByte,
            bindArray: contact
        )
        print("insertAddressBook ", rc)
        return (rc)
    }
    
    func readAddressBook( data : inout Array<AddressBookType> ) -> Int32 {
        let zSql = """
        SELECT * FROM AddressBook
        """
        let nByte : Int32 = Int32(zSql.count)
        
        let rc: Int32 = SQLiteQuere(zSql: zSql, nByte: nByte, data: &data)
        
        print("readAddressBook ", rc)
        return (rc)
    }
//    
//    func readData() {
//        let query = "select * from myDB"
//        var statement: OpaquePointer? = nil
//        
//        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
//            while sqlite3_step(statement) == SQLITE_ROW {
//                let id = sqlite3_column_int(statement, 0)
//                let overallData = String(cString: sqlite3_column_text(statement, 1))
//                do {
//                    let data = try JSONDecoder().decode(OverallData.self, from: overallData.data(using: .utf8)!)
//                    print("readData Result : \(id) \(data.candidateItem.name)")
//                } catch {
//                    print("JSONDecoder Error")
//                }
//            }
//        } else {
//            print("read Data prepare fail")
//        }
//        sqlite3_finalize(statement)
//    }
    //
    //    func deleteData() {
    //        let query = "delete from myDB where id >= 2"
    //        var statement: OpaquePointer? = nil
    //
    //        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
    //            if sqlite3_step(statement) == SQLITE_DONE {
    //                print("delete data success")
    //            } else {
    //                print("delete data step fail")
    //            }
    //        } else {
    //            print("delete data prepare fail")
    //        }
    //        sqlite3_finalize(statement)
    //    }
    //
    //    func updateData() {
    //        let query = "update myDB set id = 2 where id = 5"
    //        var statement: OpaquePointer? = nil
    //
    //        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
    //            if sqlite3_step(statement) == SQLITE_DONE {
    //                print("success updateData")
    //            } else {
    //                print("updataData sqlite3 step fail")
    //            }
    //        } else {
    //            print("updateData prepare fail")
    //        }
    //    }
    
    func QSLiteBind (ppStmt: inout OpaquePointer?, bind: NSArray) -> Int32 {
        print(bind)
        for (index, value) in bind.enumerated() {
            switch value {
            case let text as String:
                print("text", text)
                let result = sqlite3_bind_text(ppStmt, Int32(index + 1), text, -1, nil)
                if result != SQLITE_OK {
                    print("Error binding text at index \(index + 1): \(result)")
                }
            case let int as Int:
                print("int", int)
                let result = sqlite3_bind_int(ppStmt, Int32(index + 1), Int32(int))
                if result != SQLITE_OK {
                    print("Error binding integer at index \(index + 1): \(result)")
                }
            case let double as Double:
                print("double", double)
                let result = sqlite3_bind_double(ppStmt, Int32(index + 1), double)
                if result != SQLITE_OK {
                    print("Error binding double at index \(index + 1): \(result)")
                }
            case let data as Data:
                print("data", data)
                let result = sqlite3_bind_blob(ppStmt, Int32(index + 1), data.withUnsafeBytes { ptr in
                    return ptr.baseAddress!
                }, Int32(data.count), nil)
                if result != SQLITE_OK {
                    print("Error binding blob at index \(index + 1): \(result)")
                }
            default:
                print("Unsupported data type for binding at index \(index + 1)")
                return (SQLITE_MISMATCH)
            }
        }
        return(SQLITE_DONE)
    }
    
    func SQLiteQuere (zSql : String, nByte: Int32) -> Int32 {
        var ppStmt: OpaquePointer? = nil
        if (self.healthCheck != SQLITE_OK) {
            print(stderr, "Database is not open");
            sqlite3_close(db);
            return SQLITE_ERROR;
        }
        
        let rc = sqlite3_prepare_v2(self.db, zSql, nByte, &ppStmt, nil)
        if (rc != SQLITE_OK){
            print("error: prepare fail")
        }
        let stmtStep =  sqlite3_step(ppStmt);
        if (stmtStep != SQLITE_DONE) {
            print("create statement step fail")
        }
        print("Try finalize!");
        let final_rc =  sqlite3_finalize(ppStmt);
        print("final_rc :", final_rc)
        return final_rc
    }
    
    func SQLiteQuere (zSql : String, nByte: Int32, bindArray: AddressBookType) -> Int32 {
        var ppStmt: OpaquePointer? = nil
        if (self.healthCheck != SQLITE_OK) {
            print(stderr, "Database is not open");
            sqlite3_close(db);
            return SQLITE_ERROR;
        }
        
        let rc = sqlite3_prepare_v2(self.db, zSql, nByte, &ppStmt, nil)
        if (rc != SQLITE_OK){
            print("error: prepare fail")
        }
        
        sqlite3_bind_text(ppStmt, 1, bindArray.first_name, -1, nil)
        sqlite3_bind_text(ppStmt, 2, bindArray.last_name, -1, nil)
        sqlite3_bind_text(ppStmt, 3, bindArray.phone_number, -1, nil)
        
        let stmtStep =  sqlite3_step(ppStmt);
        print (stmtStep)
        if (stmtStep != SQLITE_DONE) {
            print("create statement step fail")
        }
        
        print("Try finalize!");
        return sqlite3_finalize(ppStmt);
    }
    
    func SQLiteQuere (zSql : String, nByte: Int32, data: inout Array<AddressBookType> ) -> Int32 {
        var ppStmt: OpaquePointer? = nil
        if (self.healthCheck != SQLITE_OK) {
            print(stderr, "Database is not open");
            sqlite3_close(db);
            return SQLITE_ERROR;
        }
        
        let rc = sqlite3_prepare_v2(self.db, zSql, nByte, &ppStmt, nil)
        if (rc != SQLITE_OK){
            print("error: prepare fail")
        }
        
        while sqlite3_step(ppStmt) == SQLITE_ROW {
            
            let col0 = sqlite3_column_int(ppStmt, 0) // 결과의 0번째 테이블 값
            let col1 = String(cString: sqlite3_column_text(ppStmt, 1)) // 결과의 1번째 테이블 값.
            let col2 = String(cString: sqlite3_column_text(ppStmt, 2)) // 결과의 1번째 테이블 값.
            
            print (col0, col1, col2)
        }
//        while (stmtStep == SQLITE_ROW){
//            print("data ", String(cString: sqlite3_column_text(ppStmt, 1)))
//            print("data ", String(cString: sqlite3_column_text(ppStmt, 2)))
//            print("data ", String(cString: sqlite3_column_text(ppStmt, 3)))
//            print("data ", String(cString: sqlite3_column_text(ppStmt, 4)))
//            print("data ", String(cString: sqlite3_column_text(ppStmt, 5)))
//            data.append(AddressBookType.init(
//                id: sqlite3_column_int(ppStmt, 0),
//                first_name: String(cString: sqlite3_column_text(ppStmt, 1)),
//                last_name: String(cString: sqlite3_column_text(ppStmt, 2)),
//                phone_number: String(cString:sqlite3_column_text(ppStmt, 3)),
//                create_date: String(cString:sqlite3_column_text(ppStmt, 4)),
//                update_date: String(cString:sqlite3_column_text(ppStmt, 5))
//            ))
//            stmtStep = sqlite3_step(ppStmt)
//        }
//        if (stmtStep != SQLITE_DONE) {
//            print("create statement step fail")
//        }
        print("Try finalize!");
        
        return sqlite3_finalize(ppStmt);
    }
}

