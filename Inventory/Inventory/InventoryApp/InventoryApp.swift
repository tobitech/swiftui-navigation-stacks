import AppFeature
import InventoryFeature
import ItemFeature
import ItemRowFeature
import Models
import SwiftUI

// An observable object that recursively holds onto an optional value of itself
class NestedModel: ObservableObject {
	@Published var child: NestedModel?
	init(child: NestedModel? = nil) {
		self.child = child
	}
}

struct NestedView: View {
	@ObservedObject var model: NestedModel

	var body: some View {
		NavigationLink(
			unwrapping: self.$model.child
		) { isActive in
			self.model.child = isActive ? NestedModel() : nil
		} destination: { $child in
			NestedView(model: child)
		} label: {
			Text("Go to child feature")
		}
	}
}

let lastItem = Item(
	name: "Headphones",
	color: .red,
	status: .outOfStock(isOnBackOrder: false)
)

@main
struct InventoryApp: App {
  let model = AppModel(
    inventoryModel: InventoryModel(
//			destination: .edit(
//				ItemModel(item: lastItem)
//			),
//      destination: .add(
//        ItemModel(
//          destination: .colorPicker,
//          item: Item(
//            name: "Ergnomic Keyboard",
//            status: .inStock(quantity: 100)
//          )
//        )
//      ),
      inventory: [
        ItemRowModel(
          item: Item(name: "Keyboard", color: .blue, status: .inStock(quantity: 100))
        ),
        ItemRowModel(
          item: Item(name: "Charger", color: .yellow, status: .inStock(quantity: 20))
        ),
        ItemRowModel(
          item: Item(name: "Phone", color: .green, status: .outOfStock(isOnBackOrder: true))
        ),
        ItemRowModel(
          item: Item(name: "Headphones", color: .red, status: .outOfStock(isOnBackOrder: false))
        ),
      ]
    ),
    selectedTab: .inventory
  )

  var body: some Scene {
    let _ = print("Default item ids:")
    let _ = print(model.inventoryModel.inventory.map(\.id.uuidString).joined(separator: "\n"))
    WindowGroup {
      AppView(model: self.model)
        .onOpenURL { url in
          self.model.open(url: url)
        }
    }
  }
}
