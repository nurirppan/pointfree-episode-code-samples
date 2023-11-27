import SwiftUI
import SwiftUINavigation

struct Item: Equatable, Identifiable {
  let id = UUID()
  var color: Color?
  var name: String
  var status: Status

  @CasePathable
  enum Status: Equatable {
    case inStock(quantity: Int)
    case outOfStock(isOnBackOrder: Bool)
  }

  struct Color: Equatable, Hashable {
    var name: String
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0

    static let defaults: [Self] = [
      .red,
      .green,
      .blue,
      .black,
      .yellow,
      .white,
    ]

    static let red = Self(name: "Red", red: 1)
    static let green = Self(name: "Green", green: 1)
    static let blue = Self(name: "Blue", blue: 1)
    static let black = Self(name: "Black")
    static let yellow = Self(name: "Yellow", red: 1, green: 1)
    static let white = Self(name: "White", red: 1, green: 1, blue: 1)

    var swiftUIColor: SwiftUI.Color {
      SwiftUI.Color(red: self.red, green: self.green, blue: self.blue)
    }
  }
}

extension Binding where Value: CasePathable {
  subscript<Member>(
    dynamicMember keyPath: CaseKeyPath<Value, Member>
  ) -> Binding<Member>? {
    Binding<Member>(
      unwrapping: Binding<Member?>(
        get: {
          Value.cases[keyPath: keyPath].extract(from: self.wrappedValue)
        },
        set: {
          guard let newValue = $0
          else { return }
          self.wrappedValue = Value.cases[keyPath: keyPath].embed(newValue)
        }
      )
    )
  }
}

struct ItemView: View {
  @Binding var item: Item

  var body: some View {
    Form {
      TextField("Name", text: self.$item.name)

      Picker(selection: self.$item.color, label: Text("Color")) {
        Text("None")
          .tag(Item.Color?.none)

        ForEach(Item.Color.defaults, id: \.name) { color in
          Text(color.name)
            .tag(Optional(color))
        }
      }

      switch self.item.status {
      case .inStock:
        self.$item.status.inStock.map { $quantity in
          Section(header: Text("In stock")) {
            Stepper("Quantity: \(quantity)", value: $quantity)
            Button("Mark as sold out") {
              withAnimation {
                self.item.status = .outOfStock(isOnBackOrder: false)
              }
            }
          }
          .transition(.opacity)
        }

      case .outOfStock:
        self.$item.status.outOfStock.map { $isOnBackOrder in
          Section(header: Text("Out of stock")) {
            Toggle("Is on back order?", isOn: $isOnBackOrder)
            Button("Is back in stock!") {
              withAnimation {
                self.item.status = .inStock(quantity: 1)
              }
            }
          }
          .transition(.opacity)
        }
      }

//      Switch(self.$item.status) {
//        CaseLet(/Item.Status.inStock) { $quantity in
//          Section(header: Text("In stock")) {
//            Stepper("Quantity: \(quantity)", value: $quantity)
//            Button("Mark as sold out") {
//              withAnimation {
//                self.item.status = .outOfStock(isOnBackOrder: false)
//              }
//            }
//          }
//          .transition(.opacity)
//        }
//        CaseLet(/Item.Status.outOfStock) { $isOnBackOrder in
//          Section(header: Text("Out of stock")) {
//            Toggle("Is on back order?", isOn: $isOnBackOrder)
//            Button("Is back in stock!") {
//              withAnimation {
//                self.item.status = .inStock(quantity: 1)
//              }
//            }
//          }
//          .transition(.opacity)
//        }
//      }
    }
  }
}

#Preview {
  WithState(initialValue: Item(color: nil, name: "", status: .inStock(quantity: 1))) { $item in
    ItemView(item: $item)
  }
}
