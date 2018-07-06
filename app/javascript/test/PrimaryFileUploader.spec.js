/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import PrimaryFileUploader from 'PrimaryFileUploader'

describe('PrimaryFileUploader.vue', () => {
  it('has the correct html', () => {
    const wrapper = shallowMount(PrimaryFileUploader, {
    })
    expect(wrapper.html()).toContain('<div><input name="primary_files[]" type="file" accept="application/pdf"> <br> <div class="progress"><div role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" class="progress-bar" style="width: 0%;"></div></div> </div>')
  })
})
