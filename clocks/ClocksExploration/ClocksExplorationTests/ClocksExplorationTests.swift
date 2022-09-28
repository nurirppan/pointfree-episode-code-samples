import XCTest
@testable import ClocksExploration

@MainActor
final class ClocksExplorationTests: XCTestCase {
  func testWelcome_FirstTimer() async {
    UserDefaults.standard.set(false, forKey: "hasSeenViewBefore")

    let clock = TestClock()
    let model = FeatureModel(clock: clock)

    XCTAssertEqual(model.message, "")
    let task = Task {
      await model.task()
    }
    await clock.advance(by: .seconds(5))
    await task.value
    XCTAssertEqual(model.message, "Welcome!")
  }

  func testWelcome_RepeatVisitor() async {
    UserDefaults.standard.set(true, forKey: "hasSeenViewBefore")

    let clock = TestClock()
    let model = FeatureModel(clock: clock)

    XCTAssertEqual(model.message, "")
    let task = Task {
      await model.task()
    }
    await clock.advance(by: .seconds(1))
    await task.value
    XCTAssertEqual(model.message, "Welcome!")
  }

  func testCount() async {
    let model = FeatureModel(
      clock: ContinuousClock(),
      count: 10_000
    )

    model.incrementButtonTapped()
    XCTAssertEqual(model.count, 10_001)
    model.decrementButtonTapped()
    XCTAssertEqual(model.count, 10_000)
    await model.nthPrimeButtonTapped()
    XCTAssertEqual(model.message, "10000th prime is 104729")

    // TODO: assertion on how the analytics event was tracked
  }

  func testTimer() async throws {
    let model = FeatureModel(clock: ContinuousClock())

    model.startTimerButtonTapped()
    try await Task.sleep(for: .seconds(2) + .milliseconds(100))
    model.stopTimerButtonTapped()

    XCTAssertNil(model.timerTask)
    XCTAssertEqual(model.count, 2)
  }
}
