/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import Files from 'Files'

describe('Files.vue', () => {
  global.Box = { FilePicker: function() {}}
  global.boxClientId = function() {}
  it('has 4 buttons when rendered', () => {
    const wrapper = shallowMount(Files, {
    })
    expect(wrapper.findAll('a')).toHaveLength(4)
  })

  it('has two labels ', () => {
    const wrapper = shallowMount(Files, {
    })
    
    expect(wrapper.findAll('label')).toHaveLength(2)
  })
})
