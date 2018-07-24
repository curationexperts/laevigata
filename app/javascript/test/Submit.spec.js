/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import Submit from '../Submit'

describe('Submit.vue', () => {
  it('has the correct label', () => {
    const wrapper = shallowMount(Submit, {
    })
    expect(wrapper.html()).toEqual('<section><aboutme-stub></aboutme-stub> <myprogram-stub></myprogram-stub> <myadvisor-stub></myadvisor-stub> <myetd-stub></myetd-stub> <keywords-stub></keywords-stub> <myfiles-stub></myfiles-stub> <embargo-stub></embargo-stub> <useragreement-stub></useragreement-stub></section>')
  })
})
