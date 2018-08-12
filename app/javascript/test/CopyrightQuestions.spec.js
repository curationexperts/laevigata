/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import CopyrightQuestions from 'CopyrightQuestions'
import { formStore } from '../formStore'

formStore.savedData.other_copyrights = 1
formStore.savedData.requires_permissions = 0
formStore.savedData.patents = 1

describe('CopyrightQuestions.vue', () => {
  it('has the correct html', () => {
    const wrapper = shallowMount(CopyrightQuestions, {
    })

    expect(wrapper.html()).toContain(`etd[other_copyrights]`)
    expect(wrapper.html()).toContain(`etd[requires_permissions]`)
    expect(wrapper.html()).toContain(`etd[patents]`)
  })

  it('has the correct options selected based on the state', () => {
    const wrapper = shallowMount(CopyrightQuestions, {
    })

    expect(wrapper.html()).toContain(`Yes, my thesis or dissertation contains copyrighted material.`)
    expect(wrapper.html()).toContain(`No, my thesis or dissertation does not require additional permissions.`)
    expect(wrapper.html()).toContain(`Yes, my thesis or dissertation contains patentable material.`)
  })
})
