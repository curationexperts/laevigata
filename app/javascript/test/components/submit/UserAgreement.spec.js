/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import UserAgreement from '../../../components/submit/UserAgreement'

describe('UserAgreement.vue', () => {
  it('has the correct label', () => {
    const wrapper = shallowMount(UserAgreement, {
    })
    expect(wrapper.html()).toContain('I hereby grant to Emory University')
  })
})
