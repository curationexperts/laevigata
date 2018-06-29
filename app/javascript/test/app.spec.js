/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import App from 'app.vue'

describe('App.vue', () => {
  it('renders a form', () => {
    const wrapper = shallowMount(App, {
    })
    expect(wrapper.findAll('form')).toHaveLength(1)
  })
})
