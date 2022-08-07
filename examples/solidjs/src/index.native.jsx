/* @refresh reload */
import { getRootView } from 'rehax-solidjs';
import { render } from 'rehax-solidjs/componentRenderer';

import App from './App';

render(() => <App />, getRootView());

