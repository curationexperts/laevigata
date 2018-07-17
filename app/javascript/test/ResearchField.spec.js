/* global describe */
/* global it */
/* global expect */
/* global jest */

import { shallowMount } from '@vue/test-utils'
import ResearchField from 'ResearchField'
import axios from 'axios'
jest.mock('axios')

describe('ResearchField.vue', () => {
  const resp = {data: [{'id': 'Aeronomy', 'label': '0367', 'active': true}]}
  axios.get.mockResolvedValue(resp)

  it('renders a select element', () => {
    const wrapper = shallowMount(ResearchField, {
    })
    expect(wrapper.findAll('select')).toHaveLength(3)
  })

  it('has a label that contains Research Field', () => {
    const wrapper = shallowMount(ResearchField, {
    })
    expect(wrapper.findAll('label')).toHaveLength(1)
  })

  it('has the correct html', () => {
    const wrapper = shallowMount(ResearchField, {
    })
    expect(wrapper.html()).toContain(`<div><label>Research Fields</label>`)
  })
})
