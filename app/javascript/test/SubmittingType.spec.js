/* global describe */
/* global it */
/* global expect */
/* global jest */
import { shallowMount } from '@vue/test-utils'
import SubmittingType from 'SubmittingType'
import axios from 'axios'
jest.mock('axios')

describe('SubmittingType.vue', () => {
  const resp = {data: [{'id': 'Honors Thesis', 'label': 'Honors Thesis', 'active': true}, {'id': 'Inactive', 'label': 'legacy option', 'active': false}]}
  axios.get.mockResolvedValue(resp)

  it('renders a select element', () => {
    const wrapper = shallowMount(SubmittingType, {
    })
    expect(wrapper.findAll('select')).toHaveLength(1)
  })

  it('has a label that contains Submission Type', () => {
    const wrapper = shallowMount(SubmittingType, {
    })
    expect(wrapper.findAll('label')).toHaveLength(1)
  })

  it('has the correct html', () => {
    const wrapper = shallowMount(SubmittingType, {
    })
    expect(wrapper.html()).toEqual(`<div><label for="submitting-type">Submission Type</label> <select id="submitting-type" name="etd[submitting_type]" aria-required="true" class="form-control"></select></div>`)
  })
})
