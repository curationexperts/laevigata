/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import ResearchField from 'ResearchField'

describe('ResearchField.vue', () => {
  it('renders a select element', () => {
    const wrapper = shallowMount(ResearchField, {
    })
    expect(wrapper.findAll('select')).toHaveLength(1)
  })

  it('has a label that contains Research Field', () => {
    const wrapper = shallowMount(ResearchField, {
    })
    expect(wrapper.findAll('label')).toHaveLength(1)
  })

  it('has the correct html', () => {
    const wrapper = shallowMount(ResearchField, {
    })
    expect(wrapper.html()).toEqual(`<div><label>Research Field</label> <select name="etd[research_field][]" class="form-control"></select></div>`)
  })
})
