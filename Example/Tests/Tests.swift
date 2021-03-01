import XCTest
@testable import QDNavigationBar

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
    func test_lastClassImpleMethod() {
        class Animal: NSObject {}
        class Man: Animal {
            @objc func speak() {}
        }
        class Goodman: Man{}
        class Chairman: Man {
            @objc override func speak() {}
        }
        let sel = Selector("speak")
        let obj:    AnyClass? = NSObject.lastClassImple(instanceSelector: sel)
        let animal: AnyClass? = Animal.lastClassImple(instanceSelector: sel)
        let man:    AnyClass? = Man.lastClassImple(instanceSelector: sel)
        let goodman:AnyClass? = Goodman.lastClassImple(instanceSelector: sel)
        let chairman:AnyClass? = Chairman.lastClassImple(instanceSelector: sel)
        
        XCTAssert(obj == nil)
        XCTAssert(animal == nil)
        XCTAssert(man == Man.self)
        XCTAssert(goodman == Man.self)
        XCTAssert(chairman == Chairman.self)
        
    }
    
    func test_inject() {
        class DelegateClass: NSObject {
            
        }
        let selecter = #selector(UINavigationControllerDelegate.navigationController(_:willShow:animated:))
        
        let beforeRespond = DelegateClass.instancesRespond(to: selecter)
        QDNavDelegateProxy.inject(with: DelegateClass.self)
        let afterRespond = DelegateClass.instancesRespond(to: selecter)
        XCTAssert(!beforeRespond && afterRespond)
    }
    
    // 测试直接对UINavigationController设置navBarConfig
    func test_navsetconfig() {
        let nav = UINavigationController(rootViewController: UIViewController())
        nav.navBarConfig = QDNavigationBarConfig()
    }
    
}
