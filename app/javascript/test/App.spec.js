/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import App from 'App'

describe('App.vue', () => {
  it('renders a form', () => {
    const wrapper = shallowMount(App, {
    })
    expect(wrapper.findAll('form')).toHaveLength(1)
  })
  it('updates the formStore tabs with all save-and-continue requests and progresses user from left to right through each', () => {
    const wrapper = shallowMount(App, {
    })
    // setup two tests, mocking successful and failing requests to save a tab
    // expect the tab complete property to be true on success and false on failure
    // expect the form to display errors and not increment current tab/move the user to next tab
    // expect the disabled property to be false for all tabs that are complete and the current tab
  })
})
