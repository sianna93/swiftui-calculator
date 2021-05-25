//
//  ContentView.swift
//  CalculatorSwiftUI
//
//  Created by Sianna on 5/19/21.
//

import SwiftUI

struct ContentView: View {
    
    @State var result: String = "0"
    @State var modelAction: ModelAction = ModelAction(
        valueA: "0",
        operation: .equal,
        valueB: "0",
        lastOperation: .zero,
        result: "0"
    )
    
    @State var pressAction: Bool = false
    
    var contentButtons: [[MButton]] = [
        [MButton("A/C", .gray, operation: .ac), MButton("+/-", .gray, operation: .sign), MButton("%", .gray, operation: .porcentage),
         MButton("/", .yellow, operation: .divition)],
        [MButton("7", operation: .number), MButton("8", operation: .number), MButton("9", operation: .number),
         MButton("X", .yellow, operation: .multiply)],
        [MButton("4", operation: .number), MButton("5", operation: .number), MButton("6", operation: .number),
         MButton("-", .yellow, operation: .substract)],
        [MButton("1", operation: .number), MButton("2", operation: .number), MButton("3", operation: .number),
         MButton("+", .yellow, operation: .plus)]
    ]
    
    
    var body: some View {
        
        VStack{
            Spacer(minLength: 120)
            Text("\(result)")
                .foregroundColor(.white)
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .frame( maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,
                        alignment: .bottomTrailing)
                .padding()
            VStack{
                ForEach(0..<contentButtons.count) { posx in
                    HStack{
                        ForEach(0..<contentButtons[posx].count) { posy in
                            ButtonView(
                                mButton: contentButtons[posx][posy],
                                modelAction: $modelAction,
                                result: $result,
                                pressAction: $pressAction)
                        }
                    }
                }
                HStack{
                    ButtonView(mButton:MButton("0", .double, operation: .number),
                               modelAction: $modelAction, result: $result, pressAction: $pressAction)
                    HStack{
                        ButtonView(mButton: MButton(".", operation: .comma),
                                   modelAction: $modelAction,
                                   result: $result,
                                   pressAction: $pressAction)
                        ButtonView(mButton: MButton("=", .yellow, operation: .equal),
                                   modelAction: $modelAction,
                                   result: $result,
                                   pressAction: $pressAction)
                    }
                }
            }
        }
        .padding(10)
        .background(Color.black)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ButtonView: View {
    var mButton: MButton = MButton()
       // var content: ContentButtonView = TypeButton.main.getContentBV(label: <#T##String#>, keepPress: <#T##Binding<Bool>#>)
    // var operation: Operation = .zero
    
    @Binding var modelAction: ModelAction
    @Binding var result: String
    @Binding var pressAction: Bool
    
    @State var keepPress: Bool = false

    
    
    var body: some View {
        
        Button(action: {
            
            let operation = mButton.operation

           
            
            if mButton.typeButton == .yellow && pressAction == false {
                keepPress = true
                pressAction = true
            }
            
            if mButton.typeButton == .main {
                pressAction = false
            }
            
            
            if modelAction.lastOperation == Operation.zero{
                
                if operation != .number {
                    result = "0"
                } else if mButton.text == "."  {
                    result = "0."
                } else {
                    result = mButton.text
                    modelAction.setValue(result)
                    modelAction.againOperate()
                }
            
            }
            // presiona A/C -> se reseteea
            else if operation == .ac {
                modelAction.resetValue()
                result = modelAction.result
            }
            // presiona operacion y anterior es numero -> debe mostrar resultado
            else if operation != Operation.number && modelAction.lastOperation == Operation.number{
                
                // // presiona coma y anterior es numero -> se concatena
                if operation == .comma {
                    
                    switch modelAction.lastOperation {
                        case .number:
                            
                            if !result.contains(Operation.comma.rawValue) {
                                result = "\(result)\(mButton.text)"
                                modelAction.valueB = result
                            }
                            break
                        case .comma:
                            break
                        default:
                            result = "0."
                            break
                    }
                    
                } else {
                    modelAction.againOperate()
                    result = modelAction.result
                    modelAction.setOperation(operation)
                }
                
            }
            // presiona numero y anterior es operacion -> debe mostrar numero, y no realizar operacion
            else if operation == Operation.number && modelAction.lastOperation != Operation.number{
                
                if modelAction.lastOperation == .comma {
                    result = "\(result)\(mButton.text)"
                    modelAction.valueB = result
                } else {
                    result = mButton.text
                    modelAction.setValue(result)
                }
            
            }
            // presiona numero y anterior es numero -> se concatena y solo actualiza ultimo numero, no debe hacer operacion
            
            else if operation == Operation.number && modelAction.lastOperation == Operation.number {
                
                if result.contains(Operation.comma.rawValue) {
                    result = "\(result)\(mButton.text)"
                    modelAction.valueB = result
                } else {
                    if result.first != "0" {
                        result = "\(result)\(mButton.text)"
                        modelAction.valueB = result
                    } else if result.first == "0" && mButton.text != "0"{
                        result = "\(mButton.text)"
                        modelAction.valueB = result
                    }
                }
                            
            }
            
            
            // presiona varias veces la misma action
            else if operation == modelAction.lastOperation {
                
                modelAction.operation = operation
            }
            
            else if operation == .comma && modelAction.lastOperation != .number {
                result = "0."
                modelAction.valueB = result
            }
            // presiona operacion , anterior operacion -> realiza operacion
            else {
                result = modelAction.result
                modelAction.operation = operation
            }
            modelAction.lastOperation = operation
            
           
            
        }, label: { () -> ContentButtonView in
            
            
            if mButton.typeButton == .main {
                return mButton.typeButton.getContentBV(label: mButton.text, keepPress: $keepPress)
            } else {
                return mButton.typeButton.getContentBV(label: mButton.text, keepPress: pressAction ? $keepPress : $pressAction)
            }
            
           
        })
        
            
    }
    
}


class ModelAction {
    var valueA: String
    var operation: Operation
    var valueB: String
    var lastOperation: Operation
    var result: String
    // var btnView: ButtonView
    
    
    init(valueA: String, operation: Operation, valueB: String, lastOperation: Operation, result: String) {
        self.valueA = valueA
        self.valueB = valueB
        self.operation = operation
        self.lastOperation = lastOperation
        self.result = result
    }
    
    
    
    func setValue(_ value: String) {
        self.valueA = (self.result.isEmpty || self.result == "ERROR") ? "0" : self.result
        self.valueB = value
    }
    
    func setOperation(_ operation: Operation){
        self.operation = operation
        self.valueA = self.result
        self.valueB = "0"
            
    }
    
    func resetValue(){
        self.valueB = "0"
        self.valueA = "0"
        self.operation = .equal
        self.result = "0"
    }
    
    func againOperate() {
        let valueResult =  operation.operar(a: self.valueA, b: self.valueB) ?? ""
        if (valueResult.isEmpty || valueResult == "ERROR" ){
            self.resetValue()
        }
        
        self.result = valueResult
    }
    
}

struct ContentButtonView: View {
    var label: String = ""
    var color: Color = Color(.black)
    var backgroundColor: Color = Color(.gray)
    var isCircle: Bool = true
    @Binding var keepPress: Bool
    
    var body: some View {
        if isCircle {
        Text(label)
            .font(.title)
            .foregroundColor(keepPress ? backgroundColor : color)
            .frame( maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,  maxHeight: .infinity, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            .background(keepPress ? color : backgroundColor)
            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
            .padding(1)
        } else {
            Text(label)
                .font(.title)
                .foregroundColor(keepPress ? backgroundColor : color)
                .padding(24)
                .frame( maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                .background(keepPress ? color : backgroundColor)
                .clipShape(Capsule())
                .padding(1)
        }
    }

}




struct MButton {
    var text:String
    var typeButton:TypeButton
    var operation:Operation
    //@Binding var keepPress: Bool
    
    init(){
        self.text = ""
        self.typeButton = .main
        self.operation = .zero
    }
    
    init(_ text:String, _ typeButton:TypeButton = .main, operation: Operation) {
        self.text = text
        self.typeButton = typeButton
        self.operation = operation
        //self._keepPress = keepPress
    }
    
    /*func getView()-> ContentButtonView{
        return typeButton.getContentBV(label: self.text)
    }*/
}

enum TypeButton {
    case main // buttons number
    case gray // buttons extra
    case yellow // buttons operations
    case double // button zero
    
    func getContentBV(label:String, keepPress: Binding<Bool> )-> ContentButtonView{
        switch self {
        case .main:
            return ContentButtonView(label: label,
                              color: Color.white,
                              backgroundColor: Color(red: 0.2, green: 0.2, blue: 0.2),
                              keepPress: keepPress)
        case .gray:
            return ContentButtonView(label: label,keepPress: keepPress)
            
        case .yellow:
            return ContentButtonView(label: label,
                                     color: Color(.white),
                                     backgroundColor:  Color(red: 0.9, green: 0.6, blue: 0.01),
                                     keepPress: keepPress)
        case .double:
            return ContentButtonView(label: label,
                              color: Color(.white),
                              backgroundColor: Color(red: 0.2, green: 0.2, blue: 0.2),
                              isCircle: false,
                              keepPress: keepPress)
        }
    }
}


enum Operation: String {
    case plus = "+"
    case substract = "-"
    case multiply = "x"
    case divition = "÷"
    case ac = "A/C"
    case sign = "+/-"
    case porcentage = "%"
    case comma = "."
    case equal = "="
    case number = ""
    case zero = "0"
    
    func operar(a:String, b: String) -> String? {
        
        if (b == ".") {
            return "0."
        }
        
        guard let valueA =  Float(a) else {
            return "ERROR"
        }
        
        guard let valueB =  Float(b) else {
            return "ERROR"
        }
        
        switch self {
        case .ac:
            return "0"
        case .plus:
            return "\((valueA + valueB).cleanValue)"
        case .substract:
            return "\((valueA - valueB).cleanValue)"
        case .multiply:
            return "\((valueA * valueB).cleanValue)"
        case .divition:
            if Float(b) == 0 {
                return "ERROR"
            }
            return "\((valueA / valueB).cleanValue)"
        case .equal:
            return b == "0." ? b : "\((valueB).cleanValue)"
        default:
            return nil
        }
    }
}

extension Float
{
    var cleanValue: String
    {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}



