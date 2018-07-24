/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import FinalSubmission from '../../../components/submit/FinalSubmission'
import { formStore } from '../../../formStore'

describe('FinalSubmission.vue', () => {
  it('has the correct label', () => {
    formStore.userAgreement = true
    const wrapper = shallowMount(FinalSubmission, {
    })
    expect(wrapper.html()).toContain('Submit Your Thesis or Dissertation')
  })
})
