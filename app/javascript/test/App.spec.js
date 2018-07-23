/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import App from 'App'
import axios from 'axios'
jest.mock('axios')

describe('App.vue', () => {
  it('renders a form', () => {
    const wrapper = shallowMount(App, {
    })
    expect(wrapper.findAll('form')).toHaveLength(1)
  })

  describe('Tab Navigation', () => {
    beforeEach(() => {
      const wrapper = shallowMount(App, {
      })

      wrapper.vm.$data.sharedState.tabs.about_me.complete = false
      wrapper.vm.$data.sharedState.tabs.my_program.complete = false
      wrapper.vm.$data.sharedState.tabs.my_advisor.complete = false
      wrapper.vm.$data.sharedState.tabs.my_etd.complete = false
      wrapper.vm.$data.sharedState.tabs.keywords.complete = false
      wrapper.vm.$data.sharedState.tabs.my_files.complete = false
      wrapper.vm.$data.sharedState.tabs.embargo.complete = false

      wrapper.vm.$data.sharedState.tabs.about_me.currentStep = true
      wrapper.vm.$data.sharedState.tabs.my_program.currentStep = false
      wrapper.vm.$data.sharedState.tabs.my_advisor.currentStep = false
      wrapper.vm.$data.sharedState.tabs.my_etd.currentStep = false
      wrapper.vm.$data.sharedState.tabs.keywords.currentStep = false
      wrapper.vm.$data.sharedState.tabs.my_files.currentStep = false
      wrapper.vm.$data.sharedState.tabs.embargo.currentStep = false

      wrapper.vm.$data.sharedState.enableTabs()
    });

    it('enables the completed and current tabs', () => {
      const wrapper = shallowMount(App, {
      })
      wrapper.vm.$data.sharedState.tabs.about_me.complete = true
      wrapper.vm.$data.sharedState.tabs.my_program.complete = true
      wrapper.vm.$data.sharedState.tabs.my_advisor.currentStep = true

      wrapper.vm.$data.sharedState.enableTabs()

      expect(wrapper.vm.$data.sharedState.tabs.about_me.disabled).toBe(false)
      expect(wrapper.vm.$data.sharedState.tabs.my_program.disabled).toBe(false)
      expect(wrapper.vm.$data.sharedState.tabs.my_advisor.disabled).toBe(false)
    })

    it('can set the complete property of a tab', () => {
      const wrapper = shallowMount(App, {
      })
      wrapper.vm.$data.sharedState.setComplete('About Me')

      expect(wrapper.vm.$data.sharedState.tabs.about_me.complete).toBe(true)
    })

    it('sets the current tab property', () => {
      const wrapper = shallowMount(App, {
      })
      // user has completed About Me tab, and My Program is current tab
      wrapper.vm.$data.sharedState.tabs.about_me.complete = true
      wrapper.vm.$data.sharedState.tabs.about_me.currentStep = false
      wrapper.vm.$data.sharedState.tabs.my_program.currentStep = true
      wrapper.vm.$data.sharedState.enableTabs()
      expect(wrapper.vm.$data.sharedState.tabs.about_me.currentStep).toBe(false)

      //find and click first tab
      wrapper.find('a.tab').trigger('click')

      expect(wrapper.vm.$data.sharedState.tabs.about_me.currentStep).toBe(true)
    })

    it('determines the next current tab', () => {
      const wrapper = shallowMount(App, {
      })
      wrapper.vm.$data.sharedState.nextStepIsCurrent(3)

      expect(wrapper.vm.$data.sharedState.tabs.keywords.currentStep).toBe(true)
    })

    it('prevents a user from navigating to disabled tabs', () => {
      const wrapper = shallowMount(App, {
      })
      //find and click first disabled element (My Program)
      wrapper.find('a.tab.disabled').trigger('click')

      expect(wrapper.find('h1').text()).toBe('Submit Your Thesis or Dissertation')
    })
    it("displays all of the user's data on the submit tab", () => {
      const wrapper = shallowMount(App, {
      })
    })
    it('lets the user submit their data for publication as an ETD', () => {

    })
  })
})
