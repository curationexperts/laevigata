/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import Degree from 'degree.vue'

describe('Degree.vue', () => {
  it('renders a select element', () => {
    const wrapper = shallowMount(Degree, {
    })
    expect(wrapper.findAll('select')).toHaveLength(1)
  })

  it('has a label that contains Degree', () => {
    const wrapper = shallowMount(Degree, {
    })
    console.log(wrapper.html())
    expect(wrapper.findAll('label')).toHaveLength(1)
  })

  it('has the correct html', () => {
    const wrapper = shallowMount(Degree, {
    })
    console.log(wrapper.html())
    expect(wrapper.html()).toEqual(`<div><label>Degree</label> <select name="etd[degree]" class="form-control"></select></div>`)
  })
})
