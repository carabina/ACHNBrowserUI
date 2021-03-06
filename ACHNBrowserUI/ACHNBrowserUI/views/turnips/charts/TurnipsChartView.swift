//
//  TurnipsChartView.swift
//  ACHNBrowserUI
//
//  Created by Renaud JENNY on 02/05/2020.
//  Copyright © 2020 Thomas Ricouard. All rights reserved.
//

import SwiftUI
import Backend


struct TurnipsChartView: View {
    private struct ChartHeightPreferenceKey: PreferenceKey {
        static var defaultValue: CGFloat?
        static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
            if let newValue = nextValue() { value = newValue }
        }
    }
    
    typealias PredictionCurve = TurnipsChart.PredictionCurve
    static let verticalLinesCount: CGFloat = 9
    var predictions: TurnipPredictions
    @Binding var animateCurves: Bool
    @Environment(\.presentationMode) var presentation

    @State private var chartHeight: CGFloat?
    @State private var verticalLegendWidth: CGFloat?
    @State private var bottomLegendHeight: CGFloat?
    
    var body: some View {
        VStack {
            TurnipsChartTopLegendView()
            HStack(alignment: .top) {
                TurnipsChartVerticalLegend(predictions: predictions)
                    .frame(width: verticalLegendWidth, height: chartHeight)
                    .padding(.top)
                ScrollView(.horizontal, showsIndicators: false) {
                    chart.frame(width: 600, height: 500)
                }
            }
        }
        .onHeightPreferenceChange(ChartHeightPreferenceKey.self, storeValueIn: $chartHeight)
        .onHeightPreferenceChange(TurnipsChartBottomLegendView.HeightPreferenceKey.self, storeValueIn: $bottomLegendHeight)
        .onWidthPreferenceChange(TurnipsChartVerticalLegend.WidthPreferenceKey.self, storeValueIn: $verticalLegendWidth)
    }
    
    private var chart: some View {
        VStack(spacing: 10) {
            curves
                .propagateHeight(ChartHeightPreferenceKey.self)
            TurnipsChartBottomLegendView(predictions: predictions)
                .frame(height: bottomLegendHeight)
        }
        .padding()
    }
    
    private var curves: some View {
        ZStack(alignment: .leading) {
            TurnipsChartGrid(predictions: predictions)
                .stroke()
                .opacity(0.5)
            TurnipsChartMinBuyPriceCurve(predictions: predictions)
                .stroke(style: StrokeStyle(dash: [Self.verticalLinesCount]))
                .foregroundColor(PredictionCurve.minBuyPrice.color)
                .saturation(3)
                .blendMode(.screen)
            TurnipsChartMinMaxCurves(predictions: predictions, animationStep: animateCurves ? 1 : 0.1)
                .foregroundColor(PredictionCurve.minMax.color)
                .opacity(0.25)
                .blendMode(.darken)
            TurnipsChartAverageCurve(predictions: predictions, animationStep: animateCurves ? 1 : 0)
                .stroke(lineWidth: 3)
                .foregroundColor(PredictionCurve.average.color)
                .saturation(5)
                .blendMode(.screen)
        }.animation(.spring())
    }
}

struct TurnipsChartView_Previews: PreviewProvider {
    static var previews: some View {
        TurnipsChartView(
            predictions: predictions,
            animateCurves: .constant(true)
        )
    }
    
    static let predictions = TurnipPredictions(
        minBuyPrice: 83,
        averagePrices: averagePrices,
        minMax: minMax,
        averageProfits: averageProfits
    )
    
    static let averagePrices = [89, 85, 88, 104, 110, 111, 111, 111, 106, 98, 82, 77]
    
    static let minMax = [[38, 142], [33, 142], [29, 202], [24, 602], [19, 602], [14, 602], [9, 602], [29, 602], [24, 602], [19, 602], [14, 202], [9, 201]]
    
    static let averageProfits = [89, 85, 88, 104, 110, 111, 111, 111, 106, 98, 82, 77]
}
