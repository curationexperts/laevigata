/* global describe */
/* global it */
/* global expect */
/* global jest */

import { shallowMount } from '@vue/test-utils'
import Keywords from 'Keywords'

describe('Keywords.vue', () => {
  const wrapper = shallowMount(Keywords, {
  })

  it('has the correct html', () => {
    expect(wrapper.html()).toContain('<label>Keywords</label>')
  })
})
