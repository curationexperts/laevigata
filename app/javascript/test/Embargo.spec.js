/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import Embargo from 'Embargo'
import { formStore } from '../formStore'

window.localStorage = jest.fn()
window.localStorage.getItem = jest.fn((value) => { return 'laney' } )

describe('Embargo.vue', () => {
  it('has the correct html', () => {
    const wrapper = shallowMount(Embargo, {
    })
    expect(wrapper.html()).toContain(`<select name="etd[embargo_length]" aria-required="true" id="embargo-length" class="form-control"></select>`)
  })

  it('defaults to no embargo', () => {
    const wrapper = shallowMount(Embargo, {})
    expect(wrapper.vm.selectedEmbargo).toBe(`None - open access immediately`)
    expect(wrapper.html()).toContain('<input type="hidden" name="etd[embargo_type]" id="content-to-embargo" value="open">')
  })

  it("After student has graduated, they can't edit embargo fields", () => {
    const wrapper = shallowMount(Embargo, { })
    formStore.savedData = { 'degree_awarded': 'August 23, 2018' }

    expect(wrapper.html()).toContain('This form cannot be used to edit the embargo after graduation.')
  })

  describe('Embargo saved display', () => {
    beforeEach(() => {
      const wrapper = shallowMount(Embargo, {
      })
      formStore.schools.selected = 'laney'
      formStore.savedData.schools = 'laney'
      formStore.savedData['embargo_length'] = '6 Years'
    })

    it('has the 6 Years option when Laney is the saved School', () => {
      const wrapper = shallowMount(Embargo, {
      })
      expect(wrapper.vm.selectedEmbargo).toBe(`6 Years`)
    })
  })
})
