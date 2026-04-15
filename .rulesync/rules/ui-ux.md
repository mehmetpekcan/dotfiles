---
targets:
  - '*'
root: false
description: UI/UX best practices and patterns
globs:
  - '**/*'
cursor:
  description: UI/UX best practices and patterns
  globs:
    - '**/*'
---

# UI/UX Rules

## UI/UX Best Practices

- **Slack-Like Interface:** Match Slack's visual design and interaction patterns
- **shadcn/ui Components:** Use shadcn/ui components built on Radix UI primitives
- **Tailwind CSS:** Use Tailwind utility classes for styling
- **Class Variance Authority:** Use cva for component variants
- **Accessibility First:** Ensure WCAG 2.1 AA compliance for all UI components
- **Responsive Design:** Test across mobile (320px+), tablet (768px+), and desktop (1024px+)
- **Loading States:** Always show loading indicators for async operations
- **Error States:** Provide clear, actionable error messages
- **Dark Theme:** Shack uses a dark theme inspired by Slack
- **Icon System:** Use custom icon system (lemon-lime-svgs) for Slack-compatible icons
- **Keyboard Navigation:** All interactive elements must be keyboard accessible
- **Touch Targets:** Minimum 44x44px tap targets for mobile
- **Consistent Spacing:** Use Tailwind spacing values (not arbitrary pixel values)

---

## shadcn/ui with Tailwind CSS

Shack uses shadcn/ui components with Tailwind CSS and custom Slack-inspired theming.

### Component Configuration

From `apps/frontend/components.json`:

```json
{
	"$schema": "https://ui.shadcn.com/schema.json",
	"style": "new-york",
	"rsc": true,
	"tsx": true,
	"tailwind": {"config": "", "css": "app/globals.css", "baseColor": "neutral", "cssVariables": true},
	"iconLibrary": "lucide",
	"aliases": {"components": "@/components", "utils": "@/lib/utils", "ui": "@/components/ui"}
}
```

### Basic Usage

```typescript
import { Button } from '@/components/Button/Button';
import { Badge } from '@/components/Badge/Badge';
import { Avatar, AvatarImage, AvatarFallback } from '@/components/Avatar/Avatar';

export function UserProfile({ user }) {
  return (
    <div className="flex items-center gap-3 p-4">
      <Avatar>
        <AvatarImage src={user.image_72} />
        <AvatarFallback>{user.username[0].toUpperCase()}</AvatarFallback>
      </Avatar>

      <div>
        <div className="flex items-center gap-2">
          <span className="font-bold">{user.display_name}</span>
          <Badge variant="secondary">{user.status}</Badge>
        </div>
        <p className="text-sm text-muted-foreground">@{user.username}</p>
      </div>

      <Button size="sm">Message</Button>
    </div>
  );
}
```

---

## Custom Slack Theme

### Color Palette

From `apps/frontend/app/globals.css`:

```css
@theme {
	/* Frame (sidebar header) */
	--color-shack-frame-to-bg: #401245;
	--color-shack-frame-from-bg: #230325;
	--color-shack-frame-active-bg: #69446e;

	/* Aside (sidebar) */
	--color-shack-aside-to-bg: #251228;
	--color-shack-aside-from-bg: #190c1c;
	--color-shack-aside-badge: #9d6fa7;
	--color-shack-aside-text: #b39fb9;
	--color-shack-aside-active-bg: #59335e;

	/* Content area */
	--color-shack-content-bg: #1b1d21;
	--color-shack-content-bg-hover: #222529;
	--color-shack-content-border: #383a3e;
	--color-shack-content-text: #f8f8f8;
	--color-shack-content-secondary: #d1d2d3;
	--color-shack-content-tertiary: #a0a1a2;

	/* Links */
	--color-shack-content-link: #1c93c6;
	--color-shack-content-link-hover: #40b3e4;

	/* Presence */
	--color-presence-present: #3daa7d;

	/* Z-indexes */
	--z-index-date-ruler: 800;
	--z-index-message-nav: 200;
	--z-index-message: 180;
}
```

### Using Custom Colors

```typescript
<div className="bg-shack-content-bg hover:bg-shack-content-bg-hover">
  <span className="text-shack-content-text">Heading</span>
  <p className="text-shack-content-secondary">Content</p>
  <a className="text-shack-content-link hover:text-shack-content-link-hover">
    Link
  </a>
</div>
```

---

## Component Patterns

### Button Component

From `apps/frontend/components/Button/Button.tsx`:

```typescript
import { cva, type VariantProps } from 'class-variance-authority';
import { Slot } from '@radix-ui/react-slot';
import { cn } from '@/app/lib/utils';

const buttonVariants = cva(
  'inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium transition-all disabled:pointer-events-none disabled:opacity-50',
  {
    variants: {
      variant: {
        default: 'bg-primary text-primary-foreground hover:bg-primary/90',
        destructive: 'bg-destructive text-white hover:bg-destructive/90',
        outline: 'border border-input bg-transparent shadow-xs hover:bg-accent',
        secondary: 'bg-secondary text-secondary-foreground hover:bg-secondary/80',
        ghost: 'hover:bg-accent hover:text-accent-foreground',
        link: 'text-primary underline-offset-4 hover:underline',
      },
      size: {
        default: 'h-9 px-4 py-2',
        sm: 'h-8 rounded-md gap-1.5 px-3',
        lg: 'h-10 rounded-md px-6',
        icon: 'size-9',
      },
    },
    defaultVariants: {
      variant: 'default',
      size: 'default',
    },
  },
);

export const Button = ({
  className,
  variant,
  size,
  asChild = false,
  ...props
}: React.ComponentProps<'button'> &
  VariantProps<typeof buttonVariants> & {
    asChild?: boolean;
  }) => {
  const Comp = asChild ? Slot : 'button';

  return (
    <Comp
      className={cn(buttonVariants({ variant, size, className }))}
      {...props}
    />
  );
};
```

**Usage:**

```typescript
<Button variant="default">Send Message</Button>
<Button variant="destructive">Delete Channel</Button>
<Button variant="outline" size="sm">Cancel</Button>
<Button variant="ghost" size="icon">
  <Icon id="settings" />
</Button>
```

### Message Component

From `apps/frontend/components/Message/Message.tsx`:

```typescript
'use client';

import { Avatar, AvatarImage, AvatarFallback } from '@/components/Avatar/Avatar';
import { MessageActions } from '@/components/MessageActions/MessageActions';
import { MessageReaction } from '@/components/MessageReaction/MessageReaction';

export function Message({ message }) {
  const displayName = message.user?.display_name ?? message.user?.username ?? 'Unknown';
  const avatarFallback = displayName[0]?.toUpperCase() ?? '?';
  const timestamp = new Date(message.created_at).toLocaleTimeString([], {
    hour: '2-digit',
    minute: '2-digit',
  });

  return (
    <div className="group flex gap-2 py-2 px-5 hover:bg-shack-content-bg-hover relative z-message">
      <MessageActions className="hidden group-hover:flex" />

      <Avatar>
        <AvatarImage src={message.user?.image_72} />
        <AvatarFallback>{avatarFallback}</AvatarFallback>
      </Avatar>

      <div>
        <div className="flex gap-2 items-end">
          <span className="text-sm font-bold text-[15px]">{displayName}</span>
          <span className="text-xs text-shack-content-tertiary mb-px">
            {timestamp}
          </span>
        </div>

        <div className="text-sm text-shack-content-secondary text-[15px]">
          <p>{message.content}</p>
        </div>

        {message.reactions && message.reactions.length > 0 && (
          <MessageReaction reactions={message.reactions} />
        )}
      </div>
    </div>
  );
}
```

---

## Icon System

### Custom Icon Component

From `apps/frontend/components/Icon/Icon.tsx`:

Shack uses lemon-lime-svgs for icon management:

```typescript
import type { IconProps as IconType } from '@/types/icons/icons';

interface Props {
  id: IconType;
  size?: number;
  className?: string;
  'aria-label'?: string;
}

export function Icon({ id, size = 20, className, 'aria-label': ariaLabel }: Props) {
  return (
    <svg
      width={size}
      height={size}
      className={className}
      aria-label={ariaLabel}
      aria-hidden={!ariaLabel}
    >
      <use href={`/images/icons/sprite.svg#${id}`} />
    </svg>
  );
}
```

**Usage:**

```typescript
<Icon id="messagesSolid" size={16} />
<Icon id="plus" size={20} />
<Icon id="canvasOutline" size={16} />
```

**Adding New Icons:**

1. Add SVG to `apps/frontend/other/svg-icons/`
2. Run `pnpm icons` to generate sprite
3. Icon becomes available via its filename (without .svg)

---

## Responsive Design

### Breakpoints

Tailwind default breakpoints:

- `sm`: 640px
- `md`: 768px
- `lg`: 1024px
- `xl`: 1280px
- `2xl`: 1536px

### Mobile-First Approach

```typescript
<div className="flex flex-col md:flex-row gap-4 md:gap-6 lg:gap-8 p-4 md:p-6 lg:p-8">
  <div className="w-full md:w-1/2 lg:w-1/3">Content 1</div>
  <div className="w-full md:w-1/2 lg:w-2/3">Content 2</div>
</div>
```

### Slack-Like Layout

```typescript
export default function WorkspaceLayout({ children }) {
  return (
    <div className="flex h-screen">
      {/* Sidebar */}
      <aside className="w-64 bg-gradient-to-b from-shack-aside-to-bg to-shack-aside-from-bg">
        <div className="bg-gradient-to-br from-shack-frame-to-bg to-shack-frame-from-bg p-4">
          <h1 className="text-white font-bold">Workspace Name</h1>
        </div>
        {/* Navigation */}
      </aside>

      {/* Main Content */}
      <main className="flex-1 flex flex-col bg-shack-content-bg">
        {children}
      </main>
    </div>
  );
}
```

---

## Accessibility

### Keyboard Navigation

```typescript
<button
  className="..."
  onClick={handleClick}
  onKeyDown={(e) => {
    if (e.key === 'Enter' || e.key === ' ') {
      handleClick();
    }
  }}
  aria-label="Send message"
>
  <Icon id="send" />
</button>
```

### ARIA Labels

```typescript
// Descriptive labels for screen readers
<button aria-label="Close dialog" onClick={handleClose}>
  <Icon id="x" />
</button>

// Describe state changes
<button
  aria-expanded={isOpen}
  aria-controls="channel-list"
  onClick={toggleChannels}
>
  Channels
</button>
```

### Color Contrast

Shack's theme maintains WCAG AA contrast ratios:

```typescript
// High contrast text on dark background
<p className="text-shack-content-text bg-shack-content-bg">
  High contrast (meets WCAG AA)
</p>

// Secondary text with good contrast
<p className="text-shack-content-secondary bg-shack-content-bg">
  Secondary text (meets WCAG AA)
</p>
```

---

## Loading States

### Inline Loading

```typescript
'use client';

import { api } from '@/app/lib/router/react';

export function MessageList({ channelId }: { channelId: string }) {
  const messages = api.chat.historyQuery.useQuery({ channel: channelId });

  if (messages.isLoading) {
    return (
      <div className="flex items-center justify-center h-full text-shack-content-tertiary">
        Loading messages...
      </div>
    );
  }

  if (messages.error) {
    return (
      <div className="flex items-center justify-center h-full text-red-500">
        Error loading messages
      </div>
    );
  }

  return (
    <div>
      {messages.data?.messages.map((msg) => (
        <Message key={msg.id} message={msg} />
      ))}
    </div>
  );
}
```

### Button Loading State

```typescript
'use client';

export function SendButton({ onClick, isPending }) {
  return (
    <Button disabled={isPending} onClick={onClick}>
      {isPending ? 'Sending...' : 'Send'}
    </Button>
  );
}
```

---

## Common UI Patterns

### Message List Pattern

```typescript
'use client';

import { useRef, useEffect } from 'react';
import { api } from '@/app/lib/router/react';

export function MessageList({ channelId }: { channelId: string }) {
  const scrollRef = useRef<HTMLDivElement>(null);
  const messages = api.chat.historyQuery.useQuery({ channel: channelId });

  // Auto-scroll to bottom on new messages
  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [messages.data]);

  return (
    <div className="flex-1 flex flex-col h-full overflow-hidden">
      <div ref={scrollRef} className="flex-1 overflow-y-auto">
        {messages.isLoading ? (
          <div className="flex items-center justify-center h-full">
            Loading...
          </div>
        ) : (
          <div className="flex-1 flex flex-col justify-end">
            <div className="mt-auto">
              {messages.data?.messages.map((msg) => (
                <Message key={msg.id} message={msg} />
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
```

### Sidebar Navigation Pattern

```typescript
export function ClientNav({ teamId }: { teamId: string }) {
  return (
    <nav className="flex flex-col gap-1 p-3">
      {/* Channels */}
      <div>
        <button className="flex items-center gap-2 w-full px-2 py-1 hover:bg-shack-aside-active-bg rounded text-shack-aside-text">
          <Icon id="chevronDown" size={12} />
          <span className="text-sm">Channels</span>
        </button>

        <div className="ml-4 mt-1">
          <a
            href={`/client/${teamId}/channel/general`}
            className="flex items-center gap-2 px-2 py-1 hover:bg-shack-aside-active-bg rounded text-shack-aside-text"
          >
            <Icon id="hash" size={16} />
            <span className="text-sm">general</span>
          </a>
        </div>
      </div>

      {/* Direct Messages */}
      <div className="mt-4">
        <button className="flex items-center gap-2 w-full px-2 py-1 hover:bg-shack-aside-active-bg rounded text-shack-aside-text">
          <Icon id="chevronDown" size={12} />
          <span className="text-sm">Direct messages</span>
        </button>
      </div>
    </nav>
  );
}
```

---

## Component Variants with CVA

From `apps/frontend/components/Button/Button.tsx`:

```typescript
import { cva, type VariantProps } from 'class-variance-authority';

const buttonVariants = cva(
  'inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium transition-all disabled:pointer-events-none disabled:opacity-50',
  {
    variants: {
      variant: {
        default: 'bg-primary text-primary-foreground hover:bg-primary/90',
        destructive: 'bg-destructive text-white hover:bg-destructive/90',
        outline: 'border border-input bg-transparent hover:bg-accent',
        ghost: 'hover:bg-accent hover:text-accent-foreground',
      },
      size: {
        default: 'h-9 px-4 py-2',
        sm: 'h-8 px-3',
        lg: 'h-10 px-6',
        icon: 'size-9',
      },
    },
    defaultVariants: {
      variant: 'default',
      size: 'default',
    },
  },
);

export const Button = ({
  className,
  variant,
  size,
  asChild = false,
  ...props
}: React.ComponentProps<'button'> &
  VariantProps<typeof buttonVariants> & {
    asChild?: boolean;
  }) => {
  const Comp = asChild ? Slot : 'button';
  return <Comp className={cn(buttonVariants({ variant, size, className }))} {...props} />;
};
```

---

## Radix UI Primitives

shadcn/ui is built on Radix UI primitives:

```typescript
import { Avatar, AvatarImage, AvatarFallback } from '@radix-ui/react-avatar';
import { Separator } from '@radix-ui/react-separator';
import { Toggle } from '@radix-ui/react-toggle';

// Avatar with fallback
<Avatar>
  <AvatarImage src={user.image_72} alt={user.username} />
  <AvatarFallback>{user.username[0]}</AvatarFallback>
</Avatar>

// Visual separator
<Separator orientation="horizontal" className="my-2" />

// Toggle button
<Toggle pressed={isStarred} onPressedChange={setIsStarred}>
  <Icon id="star" />
</Toggle>
```

---

## Anti-Patterns

### Don't: Use Arbitrary Values

```typescript
// ❌ BAD: Arbitrary pixel values
<div className="p-[13px] m-[27px]">
  Content
</div>

// ✅ GOOD: Tailwind spacing scale
<div className="p-4 m-6">
  Content
</div>
```

### Don't: Ignore Responsive Design

```typescript
// ❌ BAD: Fixed width on mobile
<div className="w-[800px]">
  Content
</div>

// ✅ GOOD: Responsive width
<div className="w-full lg:w-[800px]">
  Content
</div>
```

### Don't: Skip Loading States

```typescript
// ❌ BAD: No loading indicator
function DataDisplay({ channelId }) {
  const messages = api.chat.historyQuery.useQuery({ channel: channelId });
  return <div>{messages.data?.messages}</div>; // Blank while loading
}

// ✅ GOOD: Show loading state
function DataDisplay({ channelId }) {
  const messages = api.chat.historyQuery.useQuery({ channel: channelId });

  if (messages.isLoading) return <div>Loading...</div>;
  return <div>{messages.data?.messages}</div>;
}
```

---

## Storybook Integration

### Component Stories

From `apps/frontend/components/Message/Message.stories.tsx`:

```typescript
import type {Meta, StoryObj} from '@storybook/react'
import {Message} from './Message'

const meta: Meta<typeof Message> = {title: 'Components/Message', component: Message, parameters: {layout: 'padded'}}

export default meta
type Story = StoryObj<typeof Message>

export const Default: Story = {
	args: {
		message: {
			id: 'msg_123',
			content: 'Hello, world!',
			created_at: new Date(),
			user: {username: 'alice', display_name: 'Alice Johnson', image_72: null},
			reactions: []
		}
	}
}

export const WithReactions: Story = {
	args: {
		message: {
			id: 'msg_123',
			content: 'Great work team!',
			created_at: new Date(),
			user: {username: 'bob', display_name: 'Bob Smith', image_72: null},
			reactions: [
				{emoji: ':thumbsup:', user_id: 'u1'},
				{emoji: ':thumbsup:', user_id: 'u2'},
				{emoji: ':fire:', user_id: 'u3'}
			]
		}
	}
}
```

---

## Related Documentation

- [shadcn/ui Documentation](https://ui.shadcn.com/)
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)
- [Radix UI Documentation](https://www.radix-ui.com/primitives)
- [CVA Documentation](https://cva.style/docs)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- `apps/frontend/components/` - Component implementations
- `{agent_directory}/{rules_directory}/code-quality.md` - Code quality standards
