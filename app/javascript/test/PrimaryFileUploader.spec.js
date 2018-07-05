/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import PrimaryFileUploader from 'PrimaryFileUploader'

describe('PrimaryFileUploader.vue', () => {
  it('has the correct html', () => {
    const wrapper = shallowMount(PrimaryFileUploader, {
    })
    expect(wrapper.html()).toContain('<div><input name="primary_files[]" type="file"> </div>')
  })
})
