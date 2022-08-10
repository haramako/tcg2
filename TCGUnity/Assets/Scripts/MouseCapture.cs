using System.Collections;
using System.Collections.Generic;
using System.Linq;
using DG.Tweening;
using UnityEngine;
using UnityEngine.EventSystems;

public class MouseCapture : MonoBehaviour, IDragHandler, IBeginDragHandler, IEndDragHandler, IPointerDownHandler
{
    Vector3 startPositionOnBoard;
    Vector3 startPos;
    bool dragTemporaryDisabled;
    bool startClick;
    bool dragging;
    BoardObject draggingObject;

    BoardObject raycast(Vector2 screenPosition)
    {
        var ray = Camera.main.ScreenPointToRay(screenPosition);
        //Debug.Log($"{screenPosition} {Input.mousePosition} {ray}");
        //var ray = Camera.main.ScreenPointToRay(screenPosition);
        var list = Physics.RaycastAll(ray, 10.0f, LayerMask.GetMask("Default")).OrderBy(r=>r.distance);

        //Debug.Log(string.Join(",", list.Select(x => x.collider.name)));

        var found = list.Select(r =>
        {
            var obj = r.collider.gameObject.GetComponentInParent<BoardObject>();
            return obj;
        }).FirstOrDefault(x => x != null && x != draggingObject);

        return found;
    }

    Vector3 boardPoint(Vector2 screenPosition)
    {
        var ray = Camera.main.ScreenPointToRay(screenPosition);
        var plane = new Plane(Vector3.up, 0);
        if( plane.Raycast(ray, out var enter))
        {
            return ray.origin + ray.direction * enter;
        }
        else
        {
            return Vector3.zero;
        }
    }

    public void OnPointerDown(PointerEventData data)
    {
        //Debug.Log($"Down {data.position}");
        if (dragTemporaryDisabled)
        {
            return;
        }
        draggingObject = null;
        var found = raycast(data.position);
        if (found)
        {
            //Debug.Log($"PointerDown found {found} {draggingObject}");
            var movable = MainScene.Instance.Game.x("movable?", found.ObjectID).AsBool();
            if (movable)
            {
                //var pos = screenToLocal(data.position);
                startClick = true;
                startPositionOnBoard = boardPoint(data.position);
                startPos = found.transform.position;
                draggingObject = found;
            }
            else
            {
                var selectable = MainScene.Instance.Game.x("selectable?", found.ObjectID).AsBool();
                if (selectable)
                {
                    MainScene.Instance.Play(new Command("select") { Card = found.ObjectID });
                }
            }
        }
    }

    public void OnBeginDrag(PointerEventData data)
    {
        if (dragTemporaryDisabled || !startClick)
        {
            return;
        }
        //var pos = screenToLocal(data.position);
        //Debug.Log($"Begin {pos}");
        dragging = true;
        startClick = false;
    }

    public void OnDrag(PointerEventData data)
    {
        if (!dragging)
        {
            return;
        }
        //var pos = screenToLocal(data.position);
        //Debug.Log($"Drag {pos} {data.enterEventCamera}");
        var v = boardPoint(data.position) - startPositionOnBoard;
        draggingObject.transform.position = startPos + new Vector3(v.x, 0.01f, v.z);
    }

    public void OnEndDrag(PointerEventData data)
    {
        if (!dragging)
        {
            return;
        }
        var obj = draggingObject;
        startClick = false;
        dragging = false;

        //var pos = screenToLocal(data.position);
        //Debug.Log($"End {pos}");

        //var output = string.Join(", ", ); ;
        var found = raycast(data.position);

        draggingObject = null;

        if (found != null)
        {
            //Debug.Log($"Drag on {found.gameObject}");

            var movable = MainScene.Instance.Game.x("movable_to?", obj.ObjectID, found.ObjectID).AsBool();
            if (movable)
            {
                MainScene.Instance.Play(new Command("move") { Card = obj.ObjectID, MoveTo = found.ObjectID });
                return;
            }
        }

        dragTemporaryDisabled = true;
        obj.transform.DOLocalMove(startPos, 0.3f).AsyncWaitForCompletion().ContinueWith(n =>
        {
            //Debug.Log("OK");
            dragTemporaryDisabled = false;
        });
    }

}
