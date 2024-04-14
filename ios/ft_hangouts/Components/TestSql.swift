//
//  TestSql.swift
//  ft_hangouts
//
//  Created by topknell on 4/12/24.
//

import SwiftUI
import SQLite3

struct TestSql: View {
    
    var db = SQLiteController()
    
    @State var addressBook: Array<AddressBookType> = []
    @State var first_name : String="";
    @State var last_name: String="";
    @State var phone_number :String="";
    
    func contantsLoad(){
        var data: Array<AddressBookType> = []
        let rc = db.readAddressBook(data: &data)
        if (rc != SQLITE_OK){
            print("contantsLoad fail", rc)
            return ;
        }
        addressBook = data;
    }
    
    
    var body: some View {
        
        VStack(){
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            ForEach(addressBook, id: \.self.id) { content in
                Text("test")
            }
            TextField("$first_name", text: $first_name)
            
            TextField("$last_name", text: $last_name)
            
            TextField("$phone_number", text: $phone_number)
            
            Button("test",action: {
                print (db.insertAddressBook(
                    first_name: first_name,
                    last_name: last_name,
                    phone_number: phone_number)
                )
            })
            Button("test",action: {contantsLoad()}
            )
        }
    }
}

#Preview {
    TestSql()
}
