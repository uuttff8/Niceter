//
//  KeychainSwiftCBridge.swift
//  Niceter
//
//  Created by uuttff8 on 3/16/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Security
import Foundation
import KeychainSwift // You might need to remove this import in your project
/**
 
 This file can be used in your ObjC project if you want to use KeychainSwift Swift library.
 Extend this file to add other functionality for your app.
 
 How to use
 ----------
 
 1. Import swift code in your ObjC file:
 
 #import "YOUR_PRODUCT_MODULE_NAME-Swift.h"
 
 2. Use KeychainSwift in your ObjC code:
 
 - (void)viewDidLoad {
 [super viewDidLoad];
 
 KeychainSwiftCBridge *keychain = [[KeychainSwiftCBridge alloc] init];
 [keychain set:@"Hello World" forKey:@"my key"];
 NSString *value = [keychain get:@"my key"];
 
 3. You might need to remove `import KeychainSwift` import from this file in your project.
 
 */
@objc public class KeychainSwiftCBridge: NSObject {
    let keychain = KeychainSwift()
    
    @objc
    open var lastResultCode: OSStatus {
        get { return keychain.lastResultCode }
    }
    
    @objc
    open var accessGroup: String? {
        set { keychain.accessGroup = newValue }
        get { return keychain.accessGroup }
    }
    
    @objc
    open var synchronizable: Bool {
        set { keychain.synchronizable = newValue }
        get { return keychain.synchronizable }
    }
    
    
    @discardableResult
    @objc
    open func set(_ value: String, forKey key: String) -> Bool {
        return keychain.set(value, forKey: key)
    }
    
    @discardableResult
    @objc
    open func setData(_ value: Data, forKey key: String) -> Bool {
        return keychain.set(value, forKey: key)
    }
    
    @discardableResult
    @objc
    open func setBool(_ value: Bool, forKey key: String) -> Bool {
        return keychain.set(value, forKey: key)
    }
    
    @discardableResult
    @objc
    open func get(_ key: String) -> String? {
        return keychain.get(key)
    }
    
    @discardableResult
    @objc
    open func getData(_ key: String) -> Data? {
        return keychain.getData(key)
    }
    
    // the Bool? can't be represented in Obj-c
    @objc
    open func getBool(_ key: String) -> Bool {
        return keychain.getBool(key)!
    }
    
    @discardableResult
    @objc
    open func delete(_ key: String) -> Bool {
        return keychain.delete(key);
    }
    
    @discardableResult
    @objc
    open func clear() -> Bool {
        return keychain.clear()
    }
}
