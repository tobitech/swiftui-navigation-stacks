import CasePaths
import Models
import SwiftUI
import SwiftUINavigation

public final class ItemModel: Equatable, Identifiable, ObservableObject {
  @Published public var destination: Destination?
  @Published public var item: Item

  public var id: Item.ID { self.item.id }

  public enum Destination {
    case colorPicker
  }

  public init(
    destination: Destination? = nil,
    item: Item
  ) {
    self.destination = destination
    self.item = item
  }

  func setColorPickerNavigation(isActive: Bool) {
    self.destination = isActive ? .colorPicker : nil
  }

  public static func == (lhs: ItemModel, rhs: ItemModel) -> Bool {
    lhs === rhs
  }
}

public struct ItemView: View {
  @ObservedObject var model: ItemModel
  
  public init(model: ItemModel) {
    self.model = model
  }

  public var body: some View {
    Form {
      TextField("Name", text: self.$model.item.name)

      NavigationLink(
        unwrapping: self.$model.destination,
        case: /ItemModel.Destination.colorPicker
      ) { isActive in
        self.model.setColorPickerNavigation(isActive: isActive)
      } destination: { _ in 
        ColorPickerView(color: self.$model.item.color)
      } label: {
        HStack {
          Text("Color")
          Spacer()
          if let color = self.model.item.color {
            Rectangle()
              .frame(width: 30, height: 30)
              .foregroundColor(color.swiftUIColor)
              .border(Color.black, width: 1)
          }
          Text(self.model.item.color?.name ?? "None")
            .foregroundColor(.gray)
        }
      }

      Switch(self.$model.item.status) {
        CaseLet(/Item.Status.inStock) { $quantity in
          Section(header: Text("In stock")) {
            Stepper("Quantity: \(quantity)", value: $quantity)
            Button("Mark as sold out") {
              withAnimation {
                self.model.item.status = .outOfStock(isOnBackOrder: false)
              }
            }
          }
        }
//        CaseLet(/Item.Status.outOfStock) { $isOnBackOrder in
//          Section(header: Text("Out of stock")) {
//            Toggle("Is on back order?", isOn: $isOnBackOrder)
//            Button("Is back in stock!") {
//              withAnimation {
//                self.model.item.status = .inStock(quantity: 1)
//              }
//            }
//          }
//        }
      }
    }
  }
}

struct ItemView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      ItemView(
        model: ItemModel(
          item: Item(name: "", color: nil, status: .inStock(quantity: 1))
        )
      )
    }
  }
}
