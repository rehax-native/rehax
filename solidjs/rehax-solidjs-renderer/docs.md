# Element `<any>`

Native view name: View

## Properties

### `width` -> `setWidth`



`px` will be converted to setWidthFixed

`%` will be converted to setWidthPercentage

### `height` -> `setHeight`



`px` will be converted to setHeightFixed

`%` will be converted to setHeightPercentage

# Element `div`

Native view name: View

# Element `button`

Native view name: Button

# Element `input`

Native view name: TextInput

# Element `svg`

Native view name: VectorContainer

## Properties

### `fill` -> `setFill`

### `stroke` -> `setStroke`

### `strokeWidth` -> `setLineWidth`

# Element `path`

Native view name: VectorPath

## Properties

### `d`



This takes the same format as the path attribute of a svg element

It calls the `beginPath`, then the converted commands, then `endPath` of the VectorPath

M x y -> pathMoveTo(x, y)

m x y -> pathMoveBy(x, y)

L x y -> pathLineTo(x, y)

Z -> closePath

z -> closePath

