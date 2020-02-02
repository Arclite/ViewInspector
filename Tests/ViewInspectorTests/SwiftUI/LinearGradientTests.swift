import XCTest
import SwiftUI
@testable import ViewInspector

final class LinearGradientTests: XCTestCase {
    
    let gradient = Gradient(colors: [.red])
    
    func testInspect() throws {
        let sut = LinearGradient(gradient: gradient, startPoint: .bottom, endPoint: .top)
        XCTAssertNoThrow(try sut.inspect())
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(LinearGradient(gradient: gradient, startPoint: .bottom, endPoint: .top))
        XCTAssertNoThrow(try view.inspect().anyView().linearGradient())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            LinearGradient(gradient: gradient, startPoint: .bottom, endPoint: .top)
            LinearGradient(gradient: gradient, startPoint: .bottom, endPoint: .top)
        }
        XCTAssertNoThrow(try view.inspect().hStack().linearGradient(0))
        XCTAssertNoThrow(try view.inspect().hStack().linearGradient(1))
    }
    
    func testGradient() throws {
        let sut = try LinearGradient(gradient: gradient, startPoint: .bottom, endPoint: .top)
            .inspect().linearGradient().gradient()
        XCTAssertEqual(sut, gradient)
    }

    func testStartPoint() throws {
        let startPoint: UnitPoint = .topLeading
        let sut = try LinearGradient(gradient: gradient, startPoint: startPoint, endPoint: .top)
            .inspect().linearGradient().startPoint()
        XCTAssertEqual(sut, startPoint)
    }
    
    func testEndPoint() throws {
        let endPoint: UnitPoint = .topLeading
        let sut = try LinearGradient(gradient: gradient, startPoint: .bottom, endPoint: endPoint)
            .inspect().linearGradient().endPoint()
        XCTAssertEqual(sut, endPoint)
    }
}
