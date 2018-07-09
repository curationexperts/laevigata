/* global describe */
/* global it */
/* global expect */
/* global jest */

import { shallowMount } from '@vue/test-utils'
import Language from 'Language'
import axios from 'axios'
jest.mock('axios')

describe('Language.vue', () => {
  const resp = {data: [{'id': 'English', 'label': 'English', 'active': true}]}
  axios.get.mockResolvedValue(resp)

  it('renders a form', () => {
    const wrapper = shallowMount(Language, {
    })
    expect(wrapper.findAll('select')).toHaveLength(1)
  })

  it('has a label that contains Langauge', () => {
    const wrapper = shallowMount(Language, {
    })
    expect(wrapper.findAll('label')).toHaveLength(1)
  })

  it('has the correct html', () => {
    const wrapper = shallowMount(Language, {
    })
    expect(wrapper.html().replace(/\s/g, '')).toEqual('<div><label>Language</label> <select name="etd[language]" class="form-control"><option disabled="disabled" value="">Select a Language</option><!----><!----></select></div>'.replace(/\s/g, ''))
  })
})
