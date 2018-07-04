/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import SubmittingType from 'SubmittingType'

describe('SubmittingType.vue', () => {
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
    expect(wrapper.html()).toEqual(`<div><label>Submission Type</label> <select name="etd[submitting_type]" class="form-control"></select></div>`)
  })
})
