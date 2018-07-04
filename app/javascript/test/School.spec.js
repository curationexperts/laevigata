/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import Language from 'School'

describe('School.vue', () => {
  it('has the correct html', () => {
    const wrapper = shallowMount(Language, {
    })
    expect(wrapper.html()).toContain(`<div><label>School</label> <select id="school" class="form-control"><option disabled="disabled" value="">`)
  })
})
