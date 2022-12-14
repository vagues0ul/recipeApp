//
//  ContentView.swift
//  DailyCookingQuest
//
//  Created by Ahmed Faran on 12/12/2022.
//

import SwiftUI

struct ContentView: View {
    @State var manager = RecipeManager()
    @Namespace private var viewSpace
    var body: some View {
        ZStack {
            if manager.currentRecipeIndex % 2 == 0 {
                            Color.darkBackground
                                .ignoresSafeArea()
                                .transition(.move(edge: .bottom))
                                
                        } else {
                            Color.lightBackground
                                .ignoresSafeArea()
                                .transition(.move(edge: .bottom))
                                
                        }
           
            
            RecipeOverView(manager: manager)
            
        }
    }
}


struct RecipeOverView: View {
    @ObservedObject var manager: RecipeManager
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Spacer()
           // Title View
            TitleView(manager: manager)
            ZStack{
                // Interaction With Image
                RecipeInteractionView(recipe: manager.data[manager.currentRecipeIndex], index: manager.currentRecipeIndex, count: manager.data.count, manager: manager)
                    .rotationEffect(.degrees(Double(-manager.swipeHeight)))
                    .offset(x: UIScreen.screenWidth/2)
                HStack{
                    // Summery
                  
                    SummeryView(recipe: manager.data[manager.currentRecipeIndex])
                        .foregroundColor(manager.currentRecipeIndex%2 == 0 ? .black : .white)
                    Spacer()
                
    
                    
                }
                
            }
         
            DescriptionView(manager: manager)
            Spacer()
        }
    }
}



struct TitleView: View{
    @ObservedObject var manager: RecipeManager
    var body: some View{
        // Title
        Text("Cooking Quest App")
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.gray)
        
        Text(manager.data[manager.currentRecipeIndex].title)
            .font(.system(size: 22, weight: .bold))
            .foregroundColor(manager.currentRecipeIndex%2 == 0 ? .black : .white)
    }
    
} // end of title view


struct SummeryView: View {
    let recipe: RecipeItem
    var body: some View{
        VStack(alignment: .leading, spacing: 24){
            ForEach(recipe.summery.sorted(by: <), id: \.key) { key, value in
                HStack(spacing: 12){
                    Image(systemName: Data.summeryImageName[key] ?? "")
                        .foregroundColor(.green)
                    Text(value)
                }
                
            }
            
            HStack(spacing: 12){
                Image(systemName: "chart.bar.doc.horizontal")
                    .foregroundColor(.green)
                Text("Healthy")
            }
        }
        .font(.system(size: 17, weight: .semibold))
        
    }
}

struct DescriptionView: View {
    @ObservedObject var manager: RecipeManager
    var body: some View{
        Spacer()
        HStack(spacing: 12){
            Text(manager.data[manager.currentRecipeIndex].description)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(manager.currentRecipeIndex%2 == 0 ? .black : .white)
            
            Button(action:{
                withAnimation{
                    manager.selectedRecipe = manager.data[manager.currentRecipeIndex]
                }
            }, label: {
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.green)
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(45))
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
            })
        }
        
    }
}

struct RecipeInteractionView: View {
    let recipe: RecipeItem
    let index : Int
    let count : Int
    @ObservedObject var manager: RecipeManager
    var body: some View {
        ZStack{
            Circle()
                .stroke(
                LinearGradient(
                    gradient: Gradient(colors: [Color.lightBackground.opacity(0.1), Color.green, Color.green]),
                    startPoint: .leading, endPoint: .trailing
                )// end of gradent
                , lineWidth: 4
                )// end of stroke
                .scaleEffect(1.15)
            
            ArrowShape(reachedTop: index == 0, reachedBottom: index == count - 1)
                .stroke(Color.gray, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                .frame(width: UIScreen.screenWidth - 32, height: UIScreen.screenWidth - 32)
                .scaleEffect(1.25)
            
            Image(recipe.imageName)
                .resizable()
                .scaledToFit()
                
            
            Circle()
                .fill(Color.black.opacity(0.001))
                .scaleEffect(1.2)
                .gesture(
                DragGesture(minimumDistance: 10)
                    .onChanged({ value in
                        withAnimation{
                            manager.changeSwipeValue(value: value.translation.height)
                        }
                    })
                    .onEnded({ value in
                        withAnimation{
                            manager.swipeEnded(value: value.translation.height)
                        }
                    })
                )// end of drag gester
                
        }
    }
}

struct ArrowShape: Shape {
    let reachedTop: Bool
    let reachedBottom: Bool
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let startAngle: CGFloat = 160
        let endAngle: CGFloat = 200
        
        let radius = rect.width/2
        
        let startAngleRadian = startAngle * CGFloat.pi / 180
        let endAngleRadian = endAngle * CGFloat.pi / 180
        
        let startPoint1 = CGPoint.pointOnCircle(center: CGPoint(x: radius, y: radius), radius: radius, angle: startAngleRadian)
                
                let endPoint1 = CGPoint.pointOnCircle(center: CGPoint(x: radius, y: radius), radius: radius, angle: endAngleRadian)
                
                path.addArc(
                    center: CGPoint(x: radius, y: radius),
                    radius: radius,
                    startAngle: .degrees(Double(startAngle)),
                    endAngle: .degrees(Double(endAngle)),
                    clockwise: false)
        
      // start of bottom arrow sign
        if !reachedTop {
            let startAngleRadian2 = (startAngle + 4) * CGFloat.pi / 180
            let startPoint2 = CGPoint.pointOnCircle(center: CGPoint(x: radius, y: radius), radius: radius + 8, angle: startAngleRadian2)
            let startPoint3 = CGPoint.pointOnCircle(center: CGPoint(x: radius, y: radius), radius: radius - 8, angle: startAngleRadian2)
            
            path.move(to: startPoint1)
            path.addLine(to: startPoint2)
            path.move(to: startPoint1)
            path.addLine(to: startPoint3)
        }
        
        
        // start of top arrow sign
        if !reachedBottom {
            let endAngleRadian2 = (endAngle - 4) * CGFloat.pi / 180
            let endPoint2 = CGPoint.pointOnCircle(center: CGPoint(x: radius, y: radius), radius: radius + 8, angle: endAngleRadian2)
            let endPoint3 = CGPoint.pointOnCircle(center: CGPoint(x: radius, y: radius), radius: radius - 8, angle: endAngleRadian2)
            
            
            path.move(to: endPoint1)
            path.addLine(to: endPoint2)
            path.move(to: endPoint1)
            path.addLine(to: endPoint3)
        }
        
        return path
    }
    
}

extension CGPoint {
    static func pointOnCircle(center: CGPoint, radius: CGFloat, angle: CGFloat) -> CGPoint{
        let x = center.x + radius * cos(angle)
        let y = center.y + radius * sin(angle)
        return CGPoint(x: x, y: y)
    }
}


struct RecipeDetailView: View {
    var body: some View{
        VStack{
            // Title
            // Interaction With Image
            // Summary
            // Description
        }
    }
}


// start of view model

class RecipeManager: ObservableObject {
    
    @Published var data = Data.recipes
    @Published var selectedRecipe : RecipeItem? = nil
    @Published var swipeHeight: CGFloat = 0.0
    
    var currentRecipeIndex = 0
    
    func changeSwipeValue(value: CGFloat){
        swipeHeight = value/3
    }
    
    func swipeEnded(value: CGFloat){
        if value/3 > 20 || value/3 < -20 {
            var isChanged = false
            if swipeHeight > 0 {
                if currentRecipeIndex > 0{
                    currentRecipeIndex -= 1
                    swipeHeight = 360.0
                    isChanged = true
                }
            } else if swipeHeight < 0 {
                if currentRecipeIndex < data.count {
                    currentRecipeIndex += 1
                    swipeHeight = -360.0
                    isChanged = true
                }
            }
            if isChanged{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    self.swipeHeight = 0.0
                }
            } else {
                swipeHeight = 0.0
            }
        } else {
            swipeHeight = 0.0
        }
    }
    
}



// Defining the dark and light colors

extension Color {
    static let lightBackground = Color.init(red: 243/255, green: 243/255, blue: 243/255)
     static let darkBackground = Color.init(red: 34/255, green: 51/255, blue: 68/255)
} // end of colors defining


extension UIScreen {
    
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    static let screenSize = UIScreen.main.bounds.size
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
