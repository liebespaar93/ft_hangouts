# IOS 로 시작하기

## IOS SDK(Software Development Kit)

ios 를 개발하기 위해선 xcode 가 필요하다.

## VIEW

결국은 화면이란 가로와 세로로 표현되기 때문에

가로와 세로를 잘 나누어 이용해주면 모든 화면에 표현이 가능하다 (z축도 있지만 나중에)

### HStack(Horizontal Stack)

![alt text](./assets/Hstack.gif)

수평으로 작성이 가능하게 만들어 준다.
가로의 크기를 나누어 준다

### VStack(Vertical Stack)

![alt text](./assets/VStack.gif)

수직으로 작성이 가능하게 만들어 준다.
세로로 크기를 나누어 준다

이 2속성을 사용하여 화면의 ```Layout```을 잘 나누어 표현하면 된다.

> [!TIP]
> ZStack(Depth Stack) Z축으로 만들어 준다\
> 화면을 곂곂이 쌓으는게 가능해 진다\
> css 부터```z-index```로 사용되어왔기에 Z로 작성되는거 같다

### Spacer

![alt text](./assets/Spacer.gif)

사이 공간을 채우는대 사용된다
```auto-margin```과 비슷해 보인다
