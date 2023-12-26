import RealityKit

extension simd_float4x4 {
    func getOrientationMatrix() -> simd_float3x3 {
        var orientationMatrix : simd_float3x3 = simd_float3x3(0)
        
        for index_column in 0..<3 {
            for index_row in 0..<3 {
                orientationMatrix[index_column][index_row] = self[index_column][index_row]
            }
        }
        
        return orientationMatrix
    }
    
    func getFilteredOrientationMatrix() -> simd_float3x3 {
        var filteredMatrix : simd_float3x3 = simd_float3x3(0)
        var max_index : Int
        var max_value : Float
        
        for index_column in 0..<3 {
            max_index = 0
            max_value = abs(self[index_column][0])
            for index_row in 1..<3 {
                if abs(self[index_column][index_row]) > max_value { max_index = index_row }
            }
            filteredMatrix[index_column][max_index] = self[index_column][max_index]
        }
        
        return filteredMatrix
    }
    
    func getFilteredIndex() -> [Int]{
        var filteredIndex : [Int] = []
        var max_value : Float
        
        for index_column in 0..<3 {
            filteredIndex.append(0)
            max_value = abs(self[index_column][0])
            for index_row in 1..<3 {
                if abs(self[index_column][index_row]) > max_value { filteredIndex[index_column] = index_row }
            }
        }
        
        return filteredIndex
    }
}
