package
{
    public interface IMenu
    {
        function addItem(item: MenuItem, rx: uint = 0, ry: uint = 0): void;

        function getIndex(): uint;
        function setIndex(i: uint): void;

        function pressItem(): void;
    }
}

