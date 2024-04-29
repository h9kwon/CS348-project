//
//  DatabaseManager.swift
//  SampleApp
//
//  Created by 권현구 on 3/25/24.
//

import Foundation
import SQLite3

class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: OpaquePointer?

    private init() {
        // Open the SQLite database
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("app.sqlite")

        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening database")
        } else {
            print("Database opened successfully")
        }

        // Create tables if they don't exist
        createTables()
    }

    private func createTables() {
        let createItemTableQuery = """
            CREATE TABLE IF NOT EXISTS Item (
                ID INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT,
                categoryID INTEGER,
                quantity INTEGER,
                note TEXT,
                FOREIGN KEY (categoryID) REFERENCES Category(ID)
            );
            CREATE INDEX IF NOT EXISTS idx_item_categoryid ON Item (categoryID);
            """
        executeQuery(createItemTableQuery)
        
        let createCategoryTableQuery = """
            CREATE TABLE IF NOT EXISTS Category (
                ID INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT
            );
            CREATE INDEX IF NOT EXISTS idx_category_id ON Category (ID);
            CREATE INDEX IF NOT EXISTS idx_category_name ON Category (name);
            """
        executeQuery(createCategoryTableQuery)
    }

    private func executeQuery(_ query: String) {
        //Prepared Statements
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Query executed successfully")
            } else {
                print("Query execution failed")
            }
        } else {
            print("Error preparing query")
        }
        sqlite3_finalize(statement)
    }

    func insertItem(name: String, category: String, quantity: Int, note: String) {
        // First, check if the category exists in the Category table
        var categoryID: Int32 = 0
        //ORM
        let checkCategoryQuery = "SELECT ID FROM Category WHERE name = ?;"
        //Prepared Statements
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, checkCategoryQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (category as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_ROW {
                // The category exists, get its ID
                categoryID = sqlite3_column_int(statement, 0)
            } else {
                // The category doesn't exist, insert it into the Category table
                sqlite3_finalize(statement)
                
                //ORM
                let insertCategoryQuery = "INSERT INTO Category (name) VALUES (?)"
                if sqlite3_prepare_v2(db, insertCategoryQuery, -1, &statement, nil) == SQLITE_OK {
                    sqlite3_bind_text(statement, 1, (category as NSString).utf8String, -1, nil)
                    
                    if sqlite3_step(statement) == SQLITE_DONE {
                        print("Category inserted successfully")
                        categoryID = Int32(sqlite3_last_insert_rowid(db))
                    } else {
                        print("Failed to insert category")
                    }
                } else {
                    print("Error preparing statement for category insertion")
                }
            }
        } else {
            print("Error preparing statement for category check")
        }
        
        sqlite3_finalize(statement)
        
        // Now insert the item with the correct categoryID
        //ORM
        let insertItemQuery = "INSERT INTO Item (name, categoryID, quantity, note) VALUES (?, ?, ?, ?);"
        
        if sqlite3_prepare_v2(db, insertItemQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 2, categoryID)
            sqlite3_bind_int(statement, 3, Int32(quantity))
            sqlite3_bind_text(statement, 4, (note as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Item inserted successfully")
            } else {
                print("Failed to insert item")
            }
        } else {
            print("Error preparing statement for item insertion")
        }
        
        sqlite3_finalize(statement)
    }
    
    func deleteAllItems() {
        deleteAllCategories()
        //Prepared Statements
        let query = "DELETE FROM Item;"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("All items deleted successfully")
            } else {
                print("Failed to delete all items")
            }
        } else {
            print("Error preparing statement for deletion")
        }
        sqlite3_finalize(statement)
    }
    
    func deleteAllCategories() {
        //Prepared Statements
        let query = "DELETE FROM Category;"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("All categories deleted successfully")
            } else {
                print("Failed to delete all categories")
            }
        } else {
            print("Error preparing statement for category deletion")
        }
        sqlite3_finalize(statement)
    }
    
    func getFilteredItems(category: String?) -> [Item] {
        var items = [Item]()
        //Prepared Statements
        var query = "SELECT * FROM Item"
        
        //ORM
        if category != nil {
            query += " WHERE categoryID = (SELECT ID FROM Category WHERE name = ?)"
        }
        
        query += ";"
        
        //Prepared Statements
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            if let category = category {
                sqlite3_bind_text(statement, 1, (category as NSString).utf8String, -1, nil)
            }
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let name = String(cString: sqlite3_column_text(statement, 1))
                let categoryID = Int(sqlite3_column_int(statement, 2))
                let quantity = Int(sqlite3_column_int(statement, 3))
                let note = String(cString: sqlite3_column_text(statement, 4))
                
                // Fetch the category name from the Category table
                let categoryQuery = "SELECT name FROM Category WHERE ID = ?;"
                var categoryStatement: OpaquePointer?
                if sqlite3_prepare_v2(db, categoryQuery, -1, &categoryStatement, nil) == SQLITE_OK {
                    sqlite3_bind_int(categoryStatement, 1, Int32(categoryID))
                    if sqlite3_step(categoryStatement) == SQLITE_ROW {
                        let categoryName = String(cString: sqlite3_column_text(categoryStatement, 0))
                        let item = Item(id: id, name: name, category: categoryName, quantity: quantity, note: note)
                        items.append(item)
                    }
                    sqlite3_finalize(categoryStatement)
                }
            }
        } else {
            print("Error preparing statement for selection")
        }
        
        sqlite3_finalize(statement)
        return items
    }

    func getAllItems() -> [Item] {
        var items = [Item]()
        //Prepared Statements
        let query = """
            SELECT Item.ID, Item.name, Category.name, Item.quantity, Item.note
            FROM Item
            JOIN Category ON Item.categoryID = Category.ID;
            """
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let name = String(cString: sqlite3_column_text(statement, 1))
                let categoryName = String(cString: sqlite3_column_text(statement, 2))
                let quantity = Int(sqlite3_column_int(statement, 3))
                let note = String(cString: sqlite3_column_text(statement, 4))
                let item = Item(id: id, name: name, category: categoryName, quantity: quantity, note: note)
                items.append(item)
            }
        } else {
            print("Error preparing statement for selection")
        }
        sqlite3_finalize(statement)
        return items
    }
    
    func getAllCategories() -> [String] {
        var categories = [String]()
        //Prepared Statements
        let query = "SELECT name FROM Category;"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let categoryName = String(cString: sqlite3_column_text(statement, 0))
                categories.append(categoryName)
            }
        } else {
            print("Error preparing statement for category selection")
        }
        
        sqlite3_finalize(statement)
        return categories
    }
}
