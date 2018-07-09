/* global describe */
/* global it */
/* global expect */
/* global jest */
import { shallowMount } from '@vue/test-utils'
import Language from 'School'
import axios from 'axios'
jest.mock('axios')

describe('School.vue', () => {
  const resp = {data: [{'id': 'Candler School of Theology'}]}
  axios.get.mockResolvedValue(resp)

  it('has the correct html', () => {
    const wrapper = shallowMount(Language, {
    })
    expect(wrapper.html()).toContain(`<div><label>School</label> <select id="school" class="form-control"><option disabled="disabled" value="">`)
  })
})
