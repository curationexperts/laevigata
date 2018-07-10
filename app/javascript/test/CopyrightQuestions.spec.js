/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import CopyrightQuestions from 'CopyrightQuestions'

describe('CopyrightQuestions.vue', () => {
  it('has the correct html', () => {
    const wrapper = shallowMount(CopyrightQuestions, {
    })
    expect(wrapper.html()).toContain(`etd[requires_permissions]`)
    expect(wrapper.html()).toContain(`etd[additional_copyrights]`)
    expect(wrapper.html()).toContain(`etd[patents]`)
  })
})
