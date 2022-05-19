import SwiftUI

struct InternalWordTreeTestView: View {
    var body: some View {
        TestList("WordTree tests") {
            Group {
                Test(
                    "Test simple insert and lookup", 
                    { () -> (Bool, Bool, Bool, WordModel?, WordModel?) in
                        let w = WordTree(locale: .en_US)
                        return  (
                            w.add(word: "fuel"), 
                            w.add(word: "fuelss"),
                            w.add(word: "fuels"),
                            w.contains("fuels"),
                            w.contains("fuel")
                        )
                    }) 
                { data in 
                    Text(verbatim: "Failed to insert fuel: \(data.0)").testColor(good: data.0 == false)
                    Text(verbatim: "Failed to insert fuelss: \(data.1)").testColor(good: data.1 == false)
                    Text(verbatim: "Inserted fuels: \(data.2)").testColor(good: data.2)
                    Text(verbatim: "Retrieved fuels: \(data.3?.displayValue ?? "none")").testColor(good: data.3 != nil)
                    Text(verbatim: "Retrieved fuel (as a subset of fuels): \(data.4?.displayValue ?? "none")").testColor(good: data.4 != nil)
                }
                
                Test(
                    "Lookup should fail if word not present", 
                    { () -> (WordModel?) in
                        let w = WordTree(locale: .en_US)
                        return  (
                            w.contains("fuels")
                        )
                    }) 
                { data in 
                    Text(verbatim: "Retrieved fuels: \(data?.displayValue ?? "none")").testColor(good: data == nil)
                }
            }
        }
    }
}

struct InternalWordTreeTestView_Previews: PreviewProvider {
    static var previews: some View {
        InternalWordTreeTestView()
    }
}
