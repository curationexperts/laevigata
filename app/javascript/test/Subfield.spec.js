/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import Subfield from 'Subfield'


describe('Subfield.vue',() => {
  it('renders a select element', async () => {
    const wrapper = shallowMount(Subfield, {
    })
    wrapper.vm.formStore.subfields = [{ id: 'MPH', label: 'MPH' }]

    await wrapper.vm.$nextTick()
    await wrapper.vm.$forceUpdate()

    expect(wrapper.findAll('select')).toHaveLength(1)
  })

  it('has a label that contains Subfield', async () => {
    const wrapper = shallowMount(Subfield, {
    })
    wrapper.vm.formStore.subfields = [{ id: 'MPH', label: 'MPH' }]

    await wrapper.vm.$nextTick()
    await wrapper.vm.$forceUpdate()

    expect(wrapper.findAll('label')).toHaveLength(1)
  })

  it('has the correct html',  async () => {
    const wrapper = shallowMount(Subfield, {
    })
    wrapper.vm.formStore.subfields = [{ id: 'MPH', label: 'MPH' }]

    await wrapper.vm.$nextTick()
    await wrapper.vm.$forceUpdate()

    expect(wrapper.html()).toEqual(`<div><label for=\"subfield\">Subfield</label> <select id=\"subfield\" name=\"etd[subfield]\" class=\"form-control\"><option value=\"MPH\">MPH</option></select></div>`)
  })

  describe('Subfield.vue without Subfield data', () => {
    it('does not render a select element', () => {
      const wrapper = shallowMount(Subfield, {
      })
      expect(wrapper.findAll('select')).toHaveLength(0)
    })

    it('does not render a label that contains Subfield', () => {
      const wrapper = shallowMount(Subfield, {
      })
      expect(wrapper.findAll('label')).toHaveLength(0)
    })

    it('does not render the html', () => {
      const wrapper = shallowMount(Subfield, {
      })
      expect(wrapper.html()).toEqual(undefined)
    })
  })
})
