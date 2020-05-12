//
//  GittkerTests.swift
//  GittkerTests
//
//  Created by uuttff8 on 3/2/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import XCTest
@testable import Niceter

class NiceterTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testParseCreateRoom() {
        let group = GroupSchema(id: "11", name: "name", uri: "uri", homeUri: "homeUri",
                                backedBy: .init(type: "type", linkPath: "linkPath"),
                                avatarUrl: "avatarUrl")
        
        let crNonNil = ParsedCreateRoom(community: group, roomName: "Room-Name") { (_) in }
        XCTAssertNotNil(crNonNil)
        
        let crNil = ParsedCreateRoom(community: group, roomName: "Room Name") { (_) in }
        XCTAssertNil(crNil)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
