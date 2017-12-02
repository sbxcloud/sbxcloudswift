import XCTest
@testable import sbxcloudswift

class sbxcloudswiftTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        Loader<Producto>().loadAllPagesWithQuery(query)
            .subscribe(onNext:{ op in
                print("Next: \(op)")
            }, onError: { e in
                
            },
               onCompleted:{
                print("done")
            })
            .addDisposableTo(bag)
        
        XCTAssertEqual(sbxcloudswift().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
