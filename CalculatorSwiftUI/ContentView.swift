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
    
    
    var contentButtons: [[MButton]] = [
        [MButton("A/C", .gray, operation: .ac), MButton("+/-", .gray, operation: .sign), MButton("%", .gray, operation: .porcentage), MButton("/", .yellow, operation: .divition)],
        [MButton("7", operation: .number), MButton("8", operation: .number), MButton("9", operation: .number), MButton("X", .yellow, operation: .multiply)],
        [MButton("4", operation: .number), MButton("5", operation: .number), MButton("6", operation: .number), MButton("-", .yellow, operation: .substract)],
        [MButton("1", operation: .number), MButton("2", operation: .number), MButton("3", operation: .number), MButton("+", .yellow, operation: .plus)]
    ]
    
    
    var body: some View {
        VStack{
            Spacer(minLength: 120)
            Text("\(result)")
                .foregroundColor(.white)
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .padding()
            VStack{
                ForEach(0..<contentButtons.count) { posx in
                    HStack{
                        ForEach(0..<contentButtons[posx].count) { posy in
                            ButtonView(
                                content: contentButtons[posx][posy].getView(),
                                operation: contentButtons[posx][posy].operation,
                                modelAction: $modelAction,
                                result: $result)
                        }
                    }
                }
                HStack{
                    ButtonView(content:MButton("0", .double, operation: .number).getView(),
                               operation: .number,
                               modelAction: $modelAction, result: $result)
                    HStack{
                        ButtonView(content: MButton(".", operation: .comma).getView(),
                                   operation: .comma,
                                   modelAction: $modelAction,
                                   result: $result)
                        ButtonView(content: MButton("=", .yellow, operation: .equal).getView(),
                                   operation: .equal,
                                   modelAction: $modelAction,
                                   result: $result)
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
    var content: ContentButtonView
    var operation: Operation
    
    @Binding var modelAction: ModelAction
    @Binding var result: String
    
    
    var body: some View {
        
        Button(action: {
            
            if modelAction.lastOperation == Operation.zero{
                
                if operation != .number {
                    result = "0"
                } else if content.label == "."  {
                    result = "0."
                } else {
                    result = content.label
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
                                result = "\(result)\(content.label)"
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
                    result = "\(result)\(content.label)"
                    modelAction.valueB = result
                } else {
                    result = content.label
                    modelAction.setValue(result)
                }
            
            }
            // presiona numero y anterior es numero -> se concatena y solo actualiza ultimo numero, no debe hacer operacion
            
            else if operation == Operation.number && modelAction.lastOperation == Operation.number {
                
                if result.contains(Operation.comma.rawValue) {
                    result = "\(result)\(content.label)"
                    modelAction.valueB = result
                } else {
                    if result.first != "0" {
                        result = "\(result)\(content.label)"
                        modelAction.valueB = result
                    } else if result.first == "0" && content.label != "0"{
                        result = "\(content.label)"
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
            
           
        }, label: {
            content
           
        })
        
            
    }
    
}


class ModelAction {
    var valueA: String
    var operation: Operation
    var valueB: String
    var lastOperation: Operation
    var result: String
    
    
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
        // operation == .equal ? self.result :
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
    
    var body: some View {
        if isCircle {
        Text(label)
            .font(.title)
            .foregroundColor(color)
            .frame( maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,  maxHeight: .infinity, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            .background(backgroundColor)
            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
            .padding(1)
        } else {
            Text(label)
                .font(.title)
                .foregroundColor(color)
                .padding(24)
                .frame( maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .background(backgroundColor)
                .clipShape(Capsule())
                .padding(1)
        }
    }
}




struct MButton {
    var text:String
    var typeButton:TypeButton
    var operation:Operation
    
    
    init(_ text:String, _ typeButton:TypeButton = .main, operation: Operation) {
        self.text = text
        self.typeButton = typeButton
        self.operation = operation
    }
    
    func getView()-> ContentButtonView{
        return typeButton.getContentBV(label: self.text)
    }
}

enum TypeButton {
    case main
    case gray
    case yellow
    case yellowContrast
    case double
    
    func getContentBV(label:String)-> ContentButtonView{
        switch self {
        case .main:
            return ContentButtonView(label: label,
                              color: Color.white,
                              backgroundColor: Color(red: 0.2, green: 0.2, blue: 0.2))
        case .gray:
            return ContentButtonView(label: label)
            
        case .yellow:
            return ContentButtonView(label: label,
                              color: Color(.white),
                              backgroundColor: Color(red: 0.9, green: 0.6, blue: 0.01))
        case .yellowContrast:
            return ContentButtonView(label: label,
                              color: Color(red: 0.9, green: 0.6, blue: 0.01),
                              backgroundColor: Color(.white))
                            
        case .double:
            return ContentButtonView(label: label,
                              color: Color(.white),
                              backgroundColor: Color(red: 0.2, green: 0.2, blue: 0.2),
                              isCircle: false)
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



