import SaveAndSubmit from '../SaveAndSubmit'
import { formStore } from '../formStore'

test('that if you cannot successfully use the submitEtd method that an error state is set', () =>{
  var saveAndSubmit = new SaveAndSubmit({
    token: 'token',
    formData: new FormData(), 
    formStore: formStore
  })  

  // Submitting an empty form
  saveAndSubmit.submitEtd()

  expect(formStore.failedSubmission).toEqual(true)
})

test('that if you cannot successfully use the updateEtd method that an error state is set', () =>{
  var saveAndSubmit = new SaveAndSubmit({
    token: 'token',
    formData: new FormData(), 
    formStore: formStore
  })  

  document.getElementById = jest.fn()
  const xhrMockClass = () => ({
    open            : jest.fn(),
    send            : jest.fn(),
    setRequestHeader: jest.fn()
  })
  
  window.XMLHttpRequest = jest.fn().mockImplementation(xhrMockClass)
  // Submitting an empty form
  saveAndSubmit.updateEtd()

  expect(formStore.failedSubmission).toEqual(true)
})