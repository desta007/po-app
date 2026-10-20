import { useLayoutEffect } from 'react';
import { useLocation } from 'react-router-dom';

/**
 * Resets scroll to the top whenever the route path changes. React Router keeps
 * the previous page's scroll position, so without this a new page can open
 * halfway down.
 *
 * Public pages scroll the window; dashboard pages scroll AppShell's <main>,
 * which is marked with `data-scroll-root` — both are reset. Only the pathname
 * is watched, so query-string changes (filters, tabs) keep their position.
 */
export function ScrollToTop() {
  const { pathname } = useLocation();

  useLayoutEffect(() => {
    window.scrollTo(0, 0);
    document.querySelectorAll<HTMLElement>('[data-scroll-root]').forEach(el => {
      el.scrollTop = 0;
    });
  }, [pathname]);

  return null;
}
