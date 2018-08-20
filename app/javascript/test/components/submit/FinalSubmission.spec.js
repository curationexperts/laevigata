/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import FinalSubmission from '../../../components/submit/FinalSubmission'
import { formStore } from '../../../formStore'

formStore.getUserAgreement = jest.fn(() => { return false })

describe('FinalSubmission.vue', () => {
  it('has the correct label', () => {
    formStore.agreement = true
    const wrapper = shallowMount(FinalSubmission, {
    })
    expect(wrapper.html()).toContain('Submit Your Thesis or Dissertation')
  })

  it('has the correct label', () => {
    formStore.agreement = false
    const wrapper = shallowMount(FinalSubmission, {
    })
    expect(wrapper.html()).toContain('disabled')
  })
})
