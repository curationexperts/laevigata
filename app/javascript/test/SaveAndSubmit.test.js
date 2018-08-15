import SaveAndSubmit from '../SaveAndSubmit'
import { formStore } from '../formStore'

test('that if you cannot successfully use the updateEtd method that an error state is set', () =>{
  var saveAndSubmit = new SaveAndSubmit({
    token: 'token',
    formData: new FormData(), 
    formStore: formStore
  })  

  // Submitting an empty form
  saveAndSubmit.submitEtd()

  expect(formStore.failedSubmission).toEqual(true)
})