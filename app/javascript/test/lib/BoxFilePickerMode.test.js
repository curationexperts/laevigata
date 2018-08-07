import BoxFilePickerMode from '../../lib/BoxFilePickerMode'

window.localStorage = jest.fn()
window.localStorage.getItem = jest.fn()
window.localStorage.setItem = jest.fn()

test('that you can set the Box file picker moder', () => {
  var boxFilePickerMode = new BoxFilePickerMode()
  boxFilePickerMode.setMode('supplemental')
  expect(boxFilePickerMode.mode).toEqual('supplemental')
})

test('that when you try to add a bad mode, it does not work', () => {
  var boxFilePickerMode = new BoxFilePickerMode()
  boxFilePickerMode.setMode('test')
  expect(boxFilePickerMode.mode).toEqual(undefined) 
})
