/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import Embargo from 'Embargo'
import { formStore } from '../formStore'

describe('Embargo.vue', () => {
  it('has the correct html', () => {
    const wrapper = shallowMount(Embargo, {
    })
    expect(wrapper.html()).toContain(`<select name="etd[embargo_length]" aria-required="true" id="embargo-length" class="form-control"></select>`)
  })
  describe('Embargo saved display', () => {
    beforeEach(() => {
      const wrapper = shallowMount(Embargo, {
      })
      formStore.schools.selected = 'laney'
      formStore.savedData['embargo_length'] = '6 Years'
    })

    it('has the 6 Years option when Laney is the saved School', () => {
      const wrapper = shallowMount(Embargo, {
      })
      expect(wrapper.vm.selectedEmbargo).toBe(`6 Years`)
    })
  })
})
